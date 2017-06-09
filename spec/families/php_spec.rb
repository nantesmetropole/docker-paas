require "spec_helper"

require "net/fastcgi"
require 'net/http'

describe "php" do
  before(:all) do
    @php_version = ENV['PHP_VERSION'] or raise "Mandatory env: PHP_VERSION"
    @php_sapi = ENV['PHP_SAPI'] or raise "Mandatory env: PHP_SAPI"

    if not ENV['CI_REGISTRY_IMAGE'].to_s.empty?; then
      @docker_image_tag = ENV['CI_REGISTRY_IMAGE'] + ":php-#{@php_version}-#{@php_sapi}"
    else
      @docker_image_tag = "nantesmetropole/php:#{@php_version}-#{@php_sapi}"
    end
    opts = {
      'Image'      => @docker_image_tag,
      'OpenStdin'  => true,
      'StdinOnce'  => true,
      'HostConfig' => {
        'PublishAllPorts' => true,
        'ReadonlyRootfs'  => true,
        'Tmpfs'           => {
          '/run'              => 'rw,noexec,nosuid,size=65536k,uid=33', # wheezy+apache2 only?
          '/run/apache2'      => 'rw,noexec,nosuid,size=65536k,uid=33', # jessie|stretch+apache2 only ?
          '/run/lock/apache2' => 'rw,noexec,nosuid,size=65536k,uid=33', # jessie+apache2 only ?
          '/run/php'          => 'rw,noexec,nosuid,size=65536k,uid=33', # stretch+fpm only
        },
        'Binds'    => [
          "#{ENV['PWD']}/fixtures/php/phpinfo.php:/var/www/html/test/index.php:ro",
          "#{ENV['PWD']}/fixtures/php/phpversion.php:/var/www/html/test/phpversion.php:ro",
        ],
      },
    }
    @container = ::Docker::Container.create(opts)
    @container.start
    while @container.json['State'].key?('Health') && @container.json['State']['Health']['Status'] == "starting" do
      sleep 0.5
    end
    set :os, family: :debian
    set :backend, :docker
    set :docker_container, @container.id
  end

  after(:all) do
    @container.stop
    @container.delete
  end

  let(:docker_host) do
    ENV['DOCKER_HOST'] or 'localhost'
  end

  let(:http_port) do
    @container.json['NetworkSettings']['Ports']['8080/tcp'][0]["HostPort"].to_i
  end

  let(:fpm_port) do
    @container.json['NetworkSettings']['Ports']['9000/tcp'][0]["HostPort"].to_i
  end

  let(:uri) do
    if ENV['PHP_SAPI'] == 'apache2' then
      URI("http://#{docker_host}:#{http_port}/test/")
    else
      URI("fcgi://#{docker_host}:#{fpm_port}/test/")
    end
  end

  let(:client_class) do
    if ENV['PHP_SAPI'] == 'apache2' then
      Net::HTTP
    else
      Net::FastCGI
    end
  end

  # PHP tests
  it "has no error" do
    wait_server_started
    expect(@container.logs(stderr: true)).to_not include("error")
    expect(@container.logs(stderr: true)).to_not include("fatal")
    expect(@container.logs(stderr: true)).to_not include("emerg")
  end

  # Remote tests

  it "should answer requests" do
    wait_server_started

    client_class.start(uri.host, uri.port) do |client|
      request = Net::HTTP::Get.new uri + "index.php"
      response = client.request request
      expect(response.code).to eq '200'
      expect(response.body).to match /<title>phpinfo\(\)<\/title>/
    end
  end

  it "has the right version of PHP" do
    wait_server_started

    client_class.start(uri.host, uri.port) do |client|
      request = Net::HTTP::Get.new uri + "phpversion.php"
      response = client.request request
      expect(response.code).to eq '200'
      expect(response.body).to match /^#{Regexp.escape(@php_version)}\./
    end
  end

  # Helpers
  def wait_server_started
    if @php_sapi == 'apache2' then
      ok = /apache2 -D FOREGROUND/
    else
      ok = /ready to handle connections/
    end
    20.times do
        if @container.logs(stderr: true).match ok then
          break
        end
        sleep 0.5
    end
  end
end
