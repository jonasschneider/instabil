require 'omniauth-ldap'

class OmniAuth::Strategies::LDAP
  def request_phase
    f = OmniAuth::Form.new(:title => (options[:title] || "LDAP Authentication"), :url => callback_path)

    if fail_reason = request.params['fail']
      case fail_reason
      when 'credentials'
        text = 'Benutzername oder Passwort falsch.'
      when 'internal'
        text = 'Das ging schief. Ist der Schulserver down?'
      else
        text = fail_reason
      end

      f.instance_eval do
        @html << "<h3>#{text}</h3>"
      end
    end
    
    f.text_field 'Benutzername im Schulnetzwerk', 'username'
    f.password_field 'Passwort', 'password'
    f.instance_eval do
      @html << "<h4><i>(Dauert einen Moment)</i></h4>"
    end
    f.to_response
  end
end

module Instabil::Auth
  def self.registered(app)
    app.class_eval do
      configure do
        set :authorized_group_id, 10095
        set :banned_uids do (ENV["BANNED_UIDS"] || '').split(","); end
        set :whitelisted_uids do (ENV["WHITELISTED_UIDS"] || '').split(","); end
      end
      
      use OmniAuth::Builder do
        provider :fichteid, :key => ENV['FICHTE_HMAC_SECRET'] || 'mypw'
        
        if app.development? || app.test?
          provider :developer, :fields => [:username, :name, :group_ids], :uid_field => :username
        end
        
        configure do |c|
          c.on_failure = Proc.new do |env|
            puts "omniauth error: #{env["omniauth.error.type"].inspect}"
            [302, { 'Location' => '/auth/fichteid', 'Content-Type'=> 'text/plain' }, ['Das hat nicht geklappt.']]
          end
        end
      end

      use Warden::Manager do |manager|
        manager.failure_app = Proc.new do |env|
            puts "auth failure, redirecting to login"
            [302, { 'Location' => '/auth/ldap', 'Content-Type'=> 'text/plain' }, ['Log in please.']]
          end
      end
      
      Warden::Manager.serialize_into_session do |user|
        user.uid
      end
      
      Warden::Manager.serialize_from_session do |uid|
        Person.find(uid)
      end
      
      def warden
        env['warden']
      end
  
      def current_user
        warden.user
      end
      
      def authenticate!
        puts "call to authenticate!"
        warden.authenticate!
        puts "authenticated as #{current_user.uid}"
      end
      
      def authorized?(info)
        return false if settings.banned_uids.include?(info.username)
        return true if settings.whitelisted_uids.include?(info.username)
        info.group_ids.split(',').include? settings.authorized_group_id.to_s
      end
      
      def authenticate_with_info!(info)
        unless authorized?(info)
          halt 403, haml(:authfail, :layout => false)
        end
        
        user = Person.find_or_initialize_by uid: info.username
        user.uid = info.username
        
        unless user.name 
          user.name = info.name
          user.save!
        end
        puts "logged in as #{user.inspect}"
        warden.set_user user
        redirect "/"
      end
      
      if development? || test?
        post '/auth/developer/callback' do
          authenticate_with_info! env['omniauth.auth'].info
        end
      end
      
      get '/auth/fichteid/callback' do
        authenticate_with_info! env['omniauth.auth'].info
      end
      
      get '/logout' do
        warden.logout
        redirect "http://fichteid.heroku.com/sso/logout?return_to=#{url '/?logged_out=true'}"
      end
    end
  end
end