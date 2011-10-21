require 'omniauth'
require "openid"
require "openid/store/memory"

$openid_store = OpenID::Store::Memory.new

module OmniAuth
  module Strategies
    class FichteID
      include OmniAuth::Strategy
      
      option :site, "http://fichteid.heroku.com/"
      
      def consumer
        OpenID::Consumer.new(session, $openid_store)
      end
      
      def request_phase
        oidreq = consumer.begin options[:site]
        
        redirect oidreq.redirect_url("http://#{request.host_with_port}/", callback_url, false)
      end
      
      def callback_phase
        result = consumer.complete request.params, request.url
        
        if result.status == OpenID::Consumer::SUCCESS
          @data = result.get_signed_ns 'http://openid.net/extensions/sreg/1.1'
          super
        else
          fail! "authentication failed. info: #{result.inspect}"
        end
      end
        
      info do
        @data
      end
    end
  end
end

OmniAuth.config.add_camelization 'fichteid', 'FichteID'
OmniAuth.config.add_camelization 'fichte_id', 'FichteID'