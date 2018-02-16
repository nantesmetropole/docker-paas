require 'docker_paas/family/common'

module Docker_paas; module Family
  class Php < Common
    def available_php_versions
      case dist
      when 'wheezy'
        ['5.4']
      when 'jessie'
        ['5.6']
      when 'stretch'
        ['7.0']
      else
        raise "No know PHP version for: DIST=#{dist}"
      end
    end

    def self.available_php_sapis
      ['apache2', 'fpm']
    end

    def php_version
      assert_env 'PHP_VERSION', available_php_versions
    end

    def php_sapi
      v = assert_env 'PHP_SAPI'
      self.class.available_php_sapis.include?(v) or raise "Mandatory variable is not correct: PHP_SAPI=#{d}"
      v
    end

    def short_tag
      "#{php_version}-#{php_sapi}"
    end

    def php_package
      case php_version
      when /^5\./
        'php5'
      else
        "php#{php_version}"
      end
    end

    def php_packages
      case php_sapi
      when 'apache2'
        ['apache2', "libapache2-mod-#{php_package}"]
      when 'fpm'
        ["#{php_package}-#{php_sapi}"]
      end
    end

    def conf_dir
      case php_version
      when '5.4'
        '/etc/php5/conf.d'
      when '5.6'
        "/etc/php5/#{php_sapi}/conf.d"
      else
        "/etc/php/#{php_version}/#{php_sapi}/conf.d"
      end
    end

    def php_port
      case php_sapi
      when 'apache2'
        8080
      when 'fpm'
        9000
      end
    end

    def fpm_bin
      case php_version
      when /^5\./
        '/usr/sbin/php5-fpm'
      else
        "/usr/sbin/php-fpm#{php_version}"
      end
    end

    def fpm_conf_dir
      case php_version
      when /^5\./
        '/etc/php5/fpm'
      else
        "/etc/php/#{php_version}/fpm"
      end
    end

    def php_cmd
      case php_sapi
      when 'apache2'
        '["apache2-foreground"]'
      when 'fpm'
        "[\"#{fpm_bin}\"]"
      end
    end

    def before_run
      if php_sapi == 'apache2' then
        FileUtils.cp_r('templates/php/apache2-foreground', dockerfile_dir)
        super + [
          'COPY apache2-foreground /usr/local/bin/',
        ]
      else
        []
      end
    end

    def late_run
      r = []
      if php_sapi == 'apache2' then
        if dist == 'wheezy' then
          r += [
            "sed -i 's@DocumentRoot /var/www\$@DocumentRoot /var/www/html@'",
            "    /etc/apache2/sites-available/* &&",
          ]
        end
        r += [
          "sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf &&",
          "sed -i 's/^<VirtualHost \\*:80>$/<VirtualHost *:8080>/' /etc/apache2/sites-available/*default* &&",
        ]
      elsif php_sapi == 'fpm' then
        r += [
          "sed -i -e 's/^;daemonize = yes/daemonize = no/'",
          "       -e 's@^error_log =.*@error_log = /proc/self/fd/2@'",
          "    #{fpm_conf_dir}/php-fpm.conf &&",
          "sed -i -e 's/^user =/;user =/'",
          "       -e 's/^group =/;group =/'",
          "       -e 's/^listen = .*/listen = 0.0.0.0:9000/'",
          "       -e 's/^clear_env = .*/clear_env = no/'",
          "    #{fpm_conf_dir}/pool.d/www.conf &&",
        ]
      end
      r += [
        "rm -v #{conf_dir}/*",
      ]
    end

    def after_run
      [
        'USER www-data',
        '',
        "EXPOSE #{php_port}",
        '',
        'WORKDIR /var/www/html',
        '',
        "CMD #{php_cmd}",
      ]
    end

    def packages
      super + php_packages
    end
  end
end; end
