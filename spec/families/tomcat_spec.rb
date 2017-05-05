require "spec_helper"

require 'net/http'

describe "tomcat" do
  before(:all) do
    @java_version = ENV['JAVA_VERSION'] or raise "Mandatory env: JAVA_VERSION"
    @tomcat_version = ENV['TOMCAT_VERSION'] or raise "Mandatory env: TOMCAT_VERSION"
    @tomcat_package = "tomcat#{@tomcat_version.split('.')[0]}"
    @onbuild = ""
    @onbuild = "-onbuild" if ENV['ONBUILD'] == 'yes'

    if not ENV['CI_REGISTRY_IMAGE'].to_s.empty?; then
      @docker_image_tag = ENV['CI_REGISTRY_IMAGE'].sub(/paas$/, "tomcat:#{@tomcat_version}-jdk#{@java_version}#{@onbuild}")
    else
      @docker_image_tag = "nantesmetropole/tomcat:#{@tomcat_version}-jdk#{@java_version}#{@onbuild}"
    end
    opts = {
      'Image'      => @docker_image_tag,
      'OpenStdin'  => true,
      'StdinOnce'  => true,
      'HostConfig' => {
        'PublishAllPorts' => true,
        'ReadonlyRootfs'  => true,
        'Tmpfs'           => {
          '/run'                             => 'rw,noexec,nosuid,size=65536k',
          "/var/lib/#{@tomcat_package}/temp" => 'rw,noexec,nosuid,size=65536k,mode=0777',
        },
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

  # Java tests
  it "has only one version of Java" do
    expect(java_alternatives.size).to eq(1)
  end

  it "installs the right version of Java" do
    expect(java_version).to match /(java|openjdk) version "1\.#{@java_version}\./
  end

  # Tomcat tests
  it "uses the right version of tomcat" do
    wait_server_started
    ver = @tomcat_version
    ver = "#{ver}.0" unless ['8.5'].include?(@tomcat_version)
    expect(@container.logs(stderr: true)).to include("Apache Tomcat/#{ver}.")
  end

  it "uses tomcat native" do
    wait_server_started
    # On wheezy, with tomcat6:
    # "An incompatible version 1.1.24 of the APR based Apache Tomcat Native library is installed, while Tomcat requires version 1.1.30"
    pending("libtcnative-1 >= 1.1.30 on wheezy") if @tomcat_version ==  '6'
    expect(@container.logs(stderr: true)).to include("Loaded APR based Apache Tomcat Native library")
  end

  it "has no error" do
    wait_server_started
    @container.logs(stderr: true).each_line do |line|
      pending("libtcnative-1 >= 1.1.30 on wheezy") if @tomcat_version ==  '6' and
        line.include?("An incompatible version 1.1.24 of the APR based Apache Tomcat Native library is installed, while Tomcat requires version 1.1.30")
      expect(line).to_not include("GRAVE")
      expect(line).to_not include("SEVERE")
    end
  end

  # Remote tests
  it "should answer HTTP requests" do
    wait_server_started
    uri = URI("http://#{docker_host}:#{http_port}/")

    Net::HTTP.start(uri.host, uri.port) do |http|
       request = Net::HTTP::Get.new uri
       response = http.request request
       expect(response.code).to eq '200'
       expect(response.body).to match /<title>Apache Tomcat<\/title>/
       expect(response.body).to match /It works !/
    end
  end

  # Helpers
  def java_version
    command("java -version").stderr
  end

  def java_alternatives
    command("update-java-alternatives -l").stdout.split "\n"
  end

  def wait_server_started
    until @container.logs(stderr: true).match /Server startup in \d/ do
      sleep 0.5
    end
  end
end
