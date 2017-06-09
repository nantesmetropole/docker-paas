require 'docker_paas/family/common'

module Docker_paas; module Family
  class Test < Common
    def test_target
      assert_env 'TEST_TARGET', ['puppet']
    end

    def short_tag
      test_target
    end

    def early_run
      assert_env 'DIST', ['stretch']
      super + [
        # octocatalog-diff is not in stretch, take it from sid
        'head -1 /etc/apt/sources.list | sed s/stretch/sid/ > /etc/apt/sources.list.d/sid.list &&',
        "echo 'APT::Default-Release \"stretch\";' > /etc/apt/apt.conf.d/default-release &&",
      ]
    end

    def packages
      super + [
        'git',
        'octocatalog-diff',
        'puppet-lint',
        'rgxg',
        'ruby-puppetlabs-spec-helper',
        'ruby-puppet-syntax',
        'ruby-rspec-puppet',
      ]
    end

    def after_run
      [
        'USER nobody',
      ]
    end
  end
end; end
