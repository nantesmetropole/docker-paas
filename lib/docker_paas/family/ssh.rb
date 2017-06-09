require 'docker_paas/family/common'

module Docker_paas; module Family
  class Ssh < Common
    def packages
      super + ['openssh-client']
    end

    def late_run
      [
        "adduser --disabled-login --gecos 'SSH relay' --uid 1000 sshrelay",
      ]
    end

    def after_run
      [
        'USER sshrelay',
      ]
    end
  end
end; end
