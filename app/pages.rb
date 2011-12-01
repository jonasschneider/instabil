module Instabil::Pages
  def self.registered(app)
    app.class_eval do
      get '/pages/:id/edit' do
        authenticate!
        @page = Page.find(params[:id])
        @page.write_attributes params[:page]
        haml :page_edit
      end
      
      get '/pages/new' do
        authenticate!
        @page = Page.new
        haml :page_new
      end
      
      post '/pages' do
        authenticate!
        
        @user = Person.find(params[:for_person])
        redirect "/people/#{@user.id}" if @user.page
        
        @page = Page.new
        @page.write_attributes params[:page]
        @page.author = current_user
        
        if @page.save
          @user.page = @page
          @user.save!
          
          flash[:notice] = "Seite erstellt."
          redirect "/people/#{@user.id}"
        else
          flash.now[:error] = "Fehler beim Speichern. #{@page.errors.inspect}"
          haml :page_edit
        end
      end
      
      post '/pages/:id' do
        authenticate!
        @page = Page.find(params[:id])
        @page.write_attributes params[:page]
        @page.author = current_user
        
        if @page.save
          flash[:notice] = "Seite aktualisiert. #{@page.inspect}"
          redirect "/people/#{@page.person.id}"
        else
          flash.now[:error] = "Fehler beim Speichern."
          raise @page.errors.inspect
          haml :page_edit
        end
      end
    end
  end
end