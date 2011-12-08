module Instabil::People
  def self.registered(app)
    app.class_eval do
      get '/people/:uid' do
        authenticate!
        @person = Person.find(params[:uid])
        
        haml :person
      end
      
      get '/people/:uid/avatar/:style' do
        @person = Person.find params[:uid]
        
        if @person.avatar.present?
          headers 'Content-type' => @person.avatar.content_type
          @person.avatar.to_file(params[:style])
        else
          headers 'Content-type' => 'image/jpeg'
          File.open(File.join(settings.root, 'public', 'images', 'avatar.jpg'))
        end
      end
      
      post '/people/:uid/tags' do
        authenticate!
        @person = Person.find(params[:uid])
        @tag = @person.tags.build params[:tag]
        @tag.author = current_user
        
        if @tag.save
          redirect "/people/#{@person.id}"
        else
          halt 400, @tag.errors.inspect
        end
      end
    end
  end
end