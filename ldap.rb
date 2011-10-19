#!/usr/bin/env ruby
# $Id: search.cgi,v 1.1.1.1 2002/11/06 07:56:34 ttate Exp $

require 'ldap'

ldap_host = 'www.fichteportfolio.de'
ldap_port = LDAP::LDAP_PORT
ldap_base_dn = 'dc=fichteportfolio,dc=de'
ldap_filter  = 'objectClass=*'
ldap_attrs   = ('').split(",")
if( ! ldap_attrs[0] )
  ldap_attrs = nil
end
max_entries  = 50



require 'net/ldap'

ldap = Net::LDAP.new :encryption => :simple_tls, :base_dn => 'uid=schneijo,ou=accounts,dc=fichteportfolio,dc=de'
ldap.host = 'www.fichteportfolio.de'
ldap.port = 636
ldap.auth 'uid=schneijo,ou=accounts,dc=fichteportfolio,dc=de', ENV['JONASPW']
puts  ldap.bind

raise



def ldap_authenticated?(login,password)
  ldap_host = 'www.fichteportfolio.de'
  ldap_port = LDAP::LDAP_PORT
  
  

  begin
    ldap_conn = LDAP::Conn.new(ldap_host, ldap_port)
    #ldap_conn.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )
    ldap_conn.bind( login, password )
    true
    method=LDAP::LDAP_AUTH_SIMPLE
  #rescue Exception => e
  #  puts e.inspect
  #  puts 
  #  return false
  end  
end

raise ldap_authenticated?("userid=schneijo,dc=fichteportfolio,dc=de", ENV['JONASPW']).inspect


def html_tag(attr, val)
  tagged_val = val
  case attr.downcase
  when 'mail'
    tagged_val = "<a href=\"mailto:#{val}\">#{val}</a>"
  when 'telephonenumber','tel','telephone',/phone$/
    tagged_val = "<a href=\"tel:#{val.gsub(/[\(\)\-\s]/,'')}\">#{val}</a>"
  when 'fax'
    tagged_val = "<a href=\"fax:#{val.gsub(/[\(\)\-\s]/,'')}\">#{val}</a>"
  end
  case val.downcase
  when /^http:.+/
    tagged_val = "<a href=\"#{val}\">#{val}</a>"
  end
  tagged_val
end

def print_entry(entry)
  print("<table border=1>\n")
  print("<tr><td>dn</td><td>#{entry.dn}</td></tr>\n")
  entry.attrs.each{|attr|
    entry.vals(attr).each{|val|
      print("<tr><td>#{attr}</td><td>#{html_tag(attr,val)}</td></tr>\n")
    }
  }
  print("</table>\n")
  print("<p>\n")
end

begin
  ldap_conn = LDAP::Conn.new(ldap_host, ldap_port.to_i)
  ldap_conn.bind{
    puts "connected"
    i = 0
    ldap_conn.search(ldap_base_dn, LDAP::LDAP_SCOPE_SUBTREE,
		     ldap_filter, ldap_attrs){|entry|
		  puts "got 1"
      i += 1
      if( i > max_entries )
	raise(RuntimeError,"too many entries are found.")
      end
      print_entry(entry)
    }
  }
rescue LDAP::ResultError => msg
  print(msg)
rescue Exception => ex
  print(ex)
end
print("</body></html>\n")
