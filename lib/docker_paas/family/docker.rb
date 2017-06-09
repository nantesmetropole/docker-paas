require 'docker_paas/family/common'

module Docker_paas; module Family
  class Docker < Common
    def before_run
      FileUtils.cp_r('templates/docker/etc', dockerfile_dir)
      super + [
        'COPY etc/ /etc/',
      ]
    end

    def early_run
      super + [
        'apt-get update &&',
        'apt-get install -y',
        '    apt-transport-https',
        '    ca-certificates &&',
        "echo \"deb https://download.docker.com/linux/debian #{dist} stable\" > /etc/apt/sources.list.d/docker.list &&",
      ]
    end

    def packages
      super + ['docker-ce']
    end
  end
end; end
