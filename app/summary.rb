module Instabil::Summary
  def self.registered(app)
    app.class_eval do
      get '/summary' do
        authenticate!
        unless current_user.moderator?
          halt 403, 'Du bist nicht autorisiert.'
        end
        haml :summary
      end
    end
  end
end