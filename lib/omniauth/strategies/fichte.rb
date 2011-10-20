require 'omniauth'

module OmniAuth
  module Strategies
    class Fichte
      include OmniAuth::Strategy

      def request_phase
        form = OmniAuth::Form.new(:title => "Anmeldung", :url => callback_path)
        
        if request.params['error']
          msg = case request.params['error']
          when 'credentials'
            "Bitte mit Schulnetzwerk-Benutzername und -Passwort anmelden."
          when 'unauthorized'
            "Du bist nicht autorisiert. Warte noch ein paar Jahre!"
          else
            "Sonstiger Fehler."
          end
          form.html "<h4 style='color:#8A0808'>#{msg}</h2>"
        end
        
        form.text_field "Benutzername im Schulnetzwerk", "uid"
        form.password_field "Passwort im Schulnetzwerk", "password"
        
        form.button "Anmelden"
        form.to_response
      end

      def callback_phase
        res = ::Instabil::LDAP.authorize request.params['uid'], request.params['password']
        
        if res.first == true
          @entry = res.last
          super
        else
          fail! res.last
        end
      end
      
      uid do
        @entry.uid
      end

      info do
        { :name => @entry.cn.first }
      end
    end
  end
end