require 'yaml'
require 'docker_paas'

namespace :docker do
  desc "Generate Dockerfile"
  task :generate, [:family] do |t, args|
    raise "Missing parameter: family" unless args.family
    family = Docker_paas::Family.find_family "Docker_paas::Family::#{args.family.capitalize}"
    family.dockerfile_generate!
  end

  desc "Generate all Dockerfiles (from .gitlab-ci.yml)"
  task :generate_all do |t, args|
    y = YAML.load_file('.gitlab-ci.yml')
    y.each do |k, v|
      next if ['stages', 'variables'].include?(k) or k.match(/^\./)
      vars = k.split /\s+/
      sh "#{vars[1..-1].join ' '} rake docker:generate[#{vars[0]}]"
    end
  end

  desc "Build from Dockerfile"
  task :build, [:family] do |t, args|
    raise "Missing parameter: family" unless args.family
    family = Docker_paas::Family.find_family "Docker_paas::Family::#{args.family.capitalize}"
    family.docker_build!
  end

  desc "Test from Dockerfile"
  task :test, [:family] do |t, args|
    raise "Missing parameter: family" unless args.family
    family = Docker_paas::Family.find_family "Docker_paas::Family::#{args.family.capitalize}"
    family.docker_test!
  end

  desc "Save Docker image"
  task :save, [:family] do |t, args|
    raise "Missing parameter: family" unless args.family
    family = Docker_paas::Family.find_family "Docker_paas::Family::#{args.family.capitalize}"
    family.docker_save!
  end

  desc "Load Docker image"
  task :load, [:family] do |t, args|
    raise "Missing parameter: family" unless args.family
    family = Docker_paas::Family.find_family "Docker_paas::Family::#{args.family.capitalize}"
    family.docker_load!
  end

  desc "Push Docker image"
  task :push, [:family] do |t, args|
    raise "Missing parameter: family" unless args.family
    family = Docker_paas::Family.find_family "Docker_paas::Family::#{args.family.capitalize}"
    family.docker_push!
  end
end
