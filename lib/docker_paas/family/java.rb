require 'docker_paas/family/common'

module Docker_paas; module Family
  class Java < Common
    def available_java_versions
      case dist
      when 'wheezy'
        ['6', '7']
      when 'jessie'
        ['7']
      when 'stretch'
        ['8']
      else
        raise "No know Java version for: DIST=#{dist}"
      end
    end

    def java_version
      assert_env 'JAVA_VERSION', available_java_versions
    end

    def java_short
      "jdk#{java_version}"
    end

    def packages
      super + ["openjdk-#{java_version}-jre-headless"]
    end
  end
end; end
