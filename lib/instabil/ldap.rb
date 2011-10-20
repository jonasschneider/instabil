require 'net/ldap'

module Instabil
  module LDAP
    AUTHORIZED_GROUP_ID = 10095
    
    def self.authorize(user, password)
      return [false, :credentials] if user.empty? or password.empty?
      
      basedn = 'ou=accounts,dc=fichteportfolio,dc=de'
      userdn = "uid=#{user},#{basedn}"
      
      ldap = Net::LDAP.new :encryption => :simple_tls, :base_dn => basedn
      ldap.host = 'www.fichteportfolio.de'
      ldap.port = 636
      ldap.auth userdn, password
      
      if ldap.bind
        filter = Net::LDAP::Filter.eq('uid', user)
        
        ldap.search(:base => basedn, :filter => filter) do |entry|
          if entry.gidnumber.include?(AUTHORIZED_GROUP_ID.to_s)
            return [true, entry]
          else
            return [false, :unauthorized]
          end
        end
      else
        return [false, :credentials]
      end
    end
  end
end