module Instabil::Auth
  def self.registered(app)
    app.class_eval do
      use OmniAuth::Builder do
        use Rack::Session::Cookie
        
        provider :fichteid, :key => ENV['FICHTE_HMAC_SECRET'] || 'mypw'
        
        provider :developer, :fields => [:username, :name, :group_ids], :uid_field => :username
        
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
      
      post '/auth/developer/callback' do
        info = env['omniauth.auth'].info
        user = Person.find_or_initialize_by uid: info.username
        
        user.name ||= info.name
        user.save!
        
        warden.set_user user
        redirect "/"
      end
      
      get '/auth/fichteid/callback' do
        info = env['omniauth.auth'].info
        user = Person.find_or_initialize_by uid: info.username
        
        unless user.name 
          user.name = info.name
          user.save!
        end
        
        # GROUP AUTH
        warden.set_user user
        redirect "/"
      end
    end
  end
end