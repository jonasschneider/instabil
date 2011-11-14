module Instabil::Auth
  def self.registered(app)
    app.class_eval do
      get '/polls' do
        @polls = Poll.all
      end
    end
  end
end