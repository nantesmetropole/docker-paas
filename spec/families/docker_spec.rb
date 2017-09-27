require "spec_helper"

describe "docker" do
  docker_mode = ENV['DOCKER_MODE'] or raise "Mandatory env: DOCKER_MODE"

  before(:all) do
    if not ENV['CI_REGISTRY_IMAGE'].to_s.empty?; then
      @docker_image_tag = ENV['CI_REGISTRY_IMAGE'] + ':docker-' + docker_mode
    else
      @docker_image_tag = "nantesmetropole/docker:" + docker_mode
    end
    opts = {
      'Image'      => @docker_image_tag,
      'OpenStdin'  => true,
      'StdinOnce'  => true,
      'HostConfig' => {
        'PublishAllPorts' => true,
        'ReadonlyRootfs'  => true,
      },
    }
    if docker_mode == 'dind' then
      opts['HostConfig']['Privileged'] = true
      opts['HostConfig']['Tmpfs'] = {
        '/run'        => 'rw,noexec,nosuid,size=65536k',
        '/etc/docker' => 'rw,noexec,nosuid,size=65536k',
      }
    end
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

  if docker_mode == 'dind' then
    if not ENV['CI_REGISTRY_IMAGE'].to_s.empty? then
      test_image = ENV['CI_REGISTRY_IMAGE'].to_s.sub(/paas/, 'debian') + ":" + ENV['DIST']
    else
      test_image = "nantesmetropole/debian:" + ENV['DIST']
    end
    describe "dind" do
      it "should have zero images" do
        expect(command("docker images -q | wc -l").stdout).to eq("0\n")
      end
      it "should pull the '#{test_image}' image" do
        expect(command("docker pull #{test_image}").exit_status).to eq(0)
      end
      it "should have one images" do
        expect(command("docker images -q | wc -l").stdout).to eq("1\n")
      end
      it "should have zero containers" do
        expect(command("docker ps -aq | wc -l").stdout).to eq("0\n")
      end
      it "should be able to run a container 3 times from the '#{test_image}'image" do
        expect(command("docker run --rm #{test_image} true").exit_status).to eq(0)
        expect(command("docker run --rm #{test_image} true").exit_status).to eq(0)
        expect(command("docker run --rm #{test_image} true").exit_status).to eq(0)
      end
      it "should have zero containers" do
        expect(command("docker ps -aq | wc -l").stdout).to eq("0\n")
      end
      describe "test1 container" do
        it "should be able to create test1 container from the '#{test_image}'image" do
          expect(command("docker create -i --name test1 #{test_image} cat").exit_status).to eq(0)
        end
        it "should have one container" do
          expect(command("docker ps -aq | wc -l").stdout).to eq("1\n")
        end
        it "should not be running" do
          expect(command("docker inspect -f '{{.State.Running}}' test1").stdout).to eq("false\n")
        end
        it "should start" do
          expect(command("docker start test1").exit_status).to eq(0)
        end
        it "should be running" do
          expect(command("docker inspect -f '{{.State.Running}}' test1").stdout).to eq("true\n")
        end
        it "should stop" do
          expect(command("docker stop test1").exit_status).to eq(0)
        end
        it "should not be running" do
          expect(command("docker inspect -f '{{.State.Running}}' test1").stdout).to eq("false\n")
        end
        it "should rm" do
          expect(command("docker rm test1").exit_status).to eq(0)
        end
        it "should have zero containers" do
          expect(command("docker ps -aq | wc -l").stdout).to eq("0\n")
        end
      end
    end
  end
end
