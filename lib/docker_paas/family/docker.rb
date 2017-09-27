require 'docker_paas/family/common'

module Docker_paas; module Family
  class Docker < Common
    def docker_mode
      assert_env 'DOCKER_MODE', ['dind', 'latest']
    end

    def short_tag
      docker_mode
    end

    def before_run
      FileUtils.cp_r('templates/docker/etc', dockerfile_dir)
      ret = super + [
        'COPY etc/ /etc/',
      ]
      if docker_mode == 'dind' then
        FileUtils.cp_r('templates/dind', dockerfile_dir)
        ret += [
          'COPY dind/* /usr/local/bin/',
        ]
      end
      ret
    end

    def early_run
      ret = super
      if docker_mode == 'dind' then
        ret += [
          'adduser --system --group dockremap &&',
          "echo 'dockremap:165536:65536' >> /etc/subuid &&",
          "echo 'dockremap:165536:65536' >> /etc/subgid &&",
        ]
      end
      ret += [
        'apt-get update &&',
        'apt-get install -y',
        '    apt-transport-https',
        '    ca-certificates &&',
        "echo \"deb https://download.docker.com/linux/debian #{dist} stable\" > /etc/apt/sources.list.d/docker.list &&",
      ]
    end

    def packages
      p = super + ['docker-ce']
      if docker_mode == 'dind'
        p += [
          'btrfs-progs',
          'e2fsprogs',
          'xfsprogs',
        ]
      end
      p
    end

    def after_run
      if docker_mode == 'dind'
        [
          '',
          'VOLUME /var/lib/docker',
          'EXPOSE 2375',
          '',
          'ENTRYPOINT ["dockerd-entrypoint.sh"]',
          'CMD []',
        ]
      else
        []
      end
    end
  end
end; end
