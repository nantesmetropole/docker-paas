require "spec_helper"

describe "docker" do
  before(:all) do
    @docker_image_tag = "nantesmetropole/docker:latest"
    opts = {
      'Image'      => @docker_image_tag,
      'OpenStdin'  => true,
      'StdinOnce'  => true,
      'HostConfig' => {
        'PublishAllPorts' => true,
        'ReadonlyRootfs'  => true,
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

  # Docker tests
  it "has docker in PATH" do
    expect(command("docker").exit_status).to eq(0)
  end
end
