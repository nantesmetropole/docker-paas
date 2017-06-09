module Docker_paas; module Family
  class Common
    def family
      self.class.to_s.downcase.sub /^.*::/, ''
    end

    def short_tag
      'latest'
    end

    def docker_tag
      if not ENV['CI_REGISTRY_IMAGE'].to_s.empty? then
        "#{ENV['CI_REGISTRY_IMAGE']}:#{family}-#{short_tag}"
      else
        "nantesmetropole/#{family}:#{short_tag}"
      end
    end

    def assert_env(env_name, allowed_values=nil)
      e = ENV[env_name] or raise "Mandatory variable is not defined: #{env_name}"
      raise "Mandatory variable is not correct: #{env_name}=#{e} (Possible values: #{allowed_values.inspect})" unless allowed_values.nil? or allowed_values.include?(e)
      e
    end

    def dist
      assert_env 'DIST', ['wheezy', 'jessie', 'stretch']
    end

    def onbuild_suffix
      case ENV['ONBUILD']
      when 'yes'
        '-onbuild'
      when nil
        ''
      else
        raise "Mandatory variable is not correct: ONBUILD=#{ENV['ONBUILD'].inspect}"
      end
    end

    def before_run
      []
    end

    def early_run
      []
    end

    def packages
      []
    end

    def late_run
      [
        'echo Done',
      ]
    end

    def after_run
      []
    end

    def dockerfile_dir
      "#{family}/#{short_tag}"
    end

    def dockerfile_path
      "#{dockerfile_dir}/Dockerfile"
    end

    def dockerimage_path
      "#{dockerfile_dir}.tar.xz"
    end

    def dockerfile_from
      if not ENV['CI_REGISTRY_IMAGE'].to_s.empty? then
        ENV['CI_REGISTRY_IMAGE'].to_s.sub(/paas/, 'debian') + ":#{dist}"
      else
        "nantesmetropole/debian:#{dist}"
      end
    end

    def dockerfile_generate!
      FileUtils.mkdir_p(File.dirname(dockerfile_path))
      File.open(dockerfile_path, "w") do |dockerfile|
        dockerfile.write "FROM #{dockerfile_from}\n"
        if not before_run.empty? then
          dockerfile.write "\n"
          before_run.each do |r|
            dockerfile.write "#{r}\n"
          end
        end
        if not early_run.empty? or not packages.empty? or not late_run.empty? then
          dockerfile.write "\n"
          dockerfile.write "RUN set -x && \\\n"
          if not early_run.empty? then
            early_run.each do |r|
              dockerfile.write "    #{r} \\\n"
            end
          end
          if not packages.empty? then
            dockerfile.write "    apt-get update && \\\n"
            dockerfile.write "    apt-get install -y \\\n"
            packages.sort.each do |p|
              dockerfile.write "        #{p} \\\n"
            end
            dockerfile.write "    && rm -rf /var/lib/apt/lists/* && \\\n"
          end
          if not late_run.empty? then
            #require 'byebug'; byebug
            dockerfile.write (late_run.map { |r|
              "    #{r}"
            }.join " \\\n")
            dockerfile.write "\n"
          end
        end
        if not after_run.empty? then
          dockerfile.write "\n"
          after_run.each do |r|
            dockerfile.write "#{r}\n"
          end
        end
      end
    end

    def docker_build!
      system("docker build -t '#{docker_tag}' '#{dockerfile_dir}'") or
        raise "Build error"
    end

    def docker_test!
      system("rspec -fd -c 'spec/families/#{family}_spec.rb'") or
        raise "Test failed"
    end

    def docker_save!
      system("docker save '#{docker_tag}' | xz -0 > '#{dockerimage_path}'") or
        raise "Save failed"
    end

    def docker_load!
      system("cat '#{dockerimage_path}' | unxz | docker load") or
        raise "Load failed"
    end

    def docker_push!
      system("docker push '#{docker_tag}'") or
        raise "Push failed"
    end
  end
end; end
