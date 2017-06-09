require 'docker_paas/family/java'

module Docker_paas; module Family
  class Tomcat < Java
    def available_tomcat_versions
      case dist
      when 'wheezy'
        ['6', '7']
      when 'jessie'
        ['7', '8']
      when 'stretch'
        ['8.5']
      else
        raise "No know Tomcat version for: DIST=#{dist}"
      end
    end

    def tomcat_version
      assert_env 'TOMCAT_VERSION', available_tomcat_versions
    end

    def short_tag
      "#{tomcat_version}-#{java_short}#{onbuild_suffix}"
    end

    def tomcat_package
      case tomcat_version
      when '8.5'
        'tomcat8'
      else
        "tomcat#{tomcat_version}"
      end
    end

    def packages
      super + [
        'libtcnative-1',
        tomcat_package,
      ]
    end

    def late_run
      lines = []
      if tomcat_version == '6' then
        lines += [
          'cp -a /var/lib/tomcat6/webapps/ROOT/META-INF/context.xml /etc/tomcat6/Catalina/localhost/ROOT.xml &&'
        ]
      end
      lines += [
        "cp -a /etc/#{tomcat_package}/server.xml /etc/#{tomcat_package}/server.xml.orig &&",
        "cat /etc/#{tomcat_package}/server.xml.orig",
        "    | perl -0777 -pe 's/([ \\t]*<!--\\n?)(\\s+<Connector port=\"8009\"[^>]+>\\n?)(\\s+-->\\n?)/\\2/'",
        "    | perl -0777 -pe 's/([ \\t]*<!--\\n?)(\\s+<Listener className=\"org.apache.catalina.core.AprLifecycleListener\"[^>]+>\\n?)(\\s+-->\\n?)/\\2/'",
        "    > /etc/#{tomcat_package}/server.xml &&",
        "(diff -u /etc/#{tomcat_package}/server.xml.orig /etc/#{tomcat_package}/server.xml ||:)",
      ]
      lines
    end

    def after_run
      lines = [
        "ENV CATALINA_HOME=/usr/share/#{tomcat_package} \\",
        "    CATALINA_BASE=/var/lib/#{tomcat_package}",
        '',
        "USER #{tomcat_package}",
        '',
        'EXPOSE 8009 8080',
        '',
        'LABEL name="Debian Base Image" \\',
        '      vendor="Nantes Métropole"',
        '',
        "VOLUME /var/cache/#{tomcat_package} $CATALINA_BASE /var/log/#{tomcat_package}",
        '',
        "CMD [\"/usr/share/#{tomcat_package}/bin/catalina.sh\", \"run\"]",
      ]
      if onbuild_suffix != '' then
        lines += [
          '',
          'ONBUILD COPY *.war $CATALINA_BASE/webapps/',
          "ONBUILD COPY *.xml /etc/#{tomcat_package}/Catalina/localhost/",
        ]
      end
      lines
    end
  end
end; end
