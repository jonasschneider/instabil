module Instabil::Auth
  def self.registered(app)
    app.class_eval do
      use OmniAuth::Builder do
        provider :fichteid, :key => ENV['FICHTE_HMAC_SECRET'] || 'mypw'
        
        if app.development? || app.test?
          provider :developer, :fields => [:username, :name, :group_ids], :uid_field => :username
        end
        
        configure do |c|
          c.on_failure = Proc.new do |env|
            [400, { 'Content-Type'=> 'text/html'}, [env["omniauth.error.type"].inspect]]
          end
        end
      end

      use Warden::Manager do |manager|
        manager.failure_app = Proc.new do |env|
            [301, { 'Location' => '/auth/fichteid', 'Content-Type'=> 'text/plain' }, ['Log in please.']]
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
        warden.authenticate!
      end
      
      def authenticate_with_info!(info)
        unless info.group_ids.split(',').include? settings.authorized_group_id.to_s
          halt 403, haml(:authfail, :layout => false)
        end
        
        user = Person.find_or_initialize_by uid: info.username
        
        unless user.name 
          user.name = info.name
          user.save!
        end
        
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
    end
  end
end