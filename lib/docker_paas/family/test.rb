require 'docker_paas/family/common'

module Docker_paas; module Family
  class Test < Common
    def test_target
      assert_env 'TEST_TARGET', ['puppet']
    end

    def short_tag
      test_target
    end

    def packages
      super + [
        'git',
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
