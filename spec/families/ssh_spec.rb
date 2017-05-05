require "spec_helper"

describe "ssh" do
  before(:all) do
    if not ENV['CI_REGISTRY_IMAGE'].to_s.empty?; then
      @docker_image_tag = ENV['CI_REGISTRY_IMAGE'] + ':ssh-latest'
    else
      @docker_image_tag = "nantesmetropole/ssh:latest"
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

  # SSH tests
  it "has ssh in PATH" do
    expect(command('ssh').exit_status).to eq(255)
  end

  it "user is nobody" do
    expect(command('id -un').stdout.strip).to eq('nobody')
  end
end
