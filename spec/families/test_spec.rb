require "spec_helper"

describe "test" do
  before(:all) do
    if not ENV['CI_REGISTRY_IMAGE'].to_s.empty?; then
      @docker_image_tag = ENV['CI_REGISTRY_IMAGE'] + ':test-' + ENV['TEST_TARGET']
    else
      @docker_image_tag = "nantesmetropole/test:" + ENV['TEST_TARGET']
    end

    opts = {
      'Image'      => @docker_image_tag,
      'OpenStdin'  => true,
      'StdinOnce'  => true,
      'Cmd'        => ['/bin/sh', '-c', 'read wait'],
      'HostConfig' => {
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

  # test:puppet tests
  it "has rspec in PATH" do
    expect(command('rspec --version').exit_status).to eq(0)
  end

  it "has octocatalog-diff in PATH" do
    expect(command('octocatalog-diff --version').exit_status).to eq(0)
  end
end
