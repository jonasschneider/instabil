module Instabil::Versions
  def self.registered(app)
    app.class_eval do
      get '/people/:uid/page/versions' do
        authenticate!
        @person = Person.find(params[:uid])
        @page = @person.page
        @versions = @page.versions
        
        haml :versions
      end
    end
  end
end