require 'docker_paas/family/docker'
#require 'docker_paas/family/java'
require 'docker_paas/family/php'
require 'docker_paas/family/ssh'
require 'docker_paas/family/test'
require 'docker_paas/family/tomcat'

module Docker_paas; module Family
  class << self
    def find_family(family_constant)
      family =  Family.const_get(family_constant).new
    end
  end
end; end
