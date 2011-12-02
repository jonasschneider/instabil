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
        @target = params[:for_person] ? Person.find(params[:for_person]) : Course.find(params[:for_course])
        haml :page_new
      end
      
      post '/pages' do
        authenticate!
        
        @target = params[:for_person] ? Person.find(params[:for_person]) : Course.find(params[:for_course])
        
        @page = Page.new
        @page.write_attributes params[:page]
        @page.author = current_user
        
        if @target.page.nil?
          if @page.save
            @target.page = @page
            @target.save!
            
            flash[:notice] = "Seite erstellt."
            if params[:for_person]
              redirect "/people/#{@target.id}"
            else
              redirect "/courses"
            end
          else
            flash.now[:error] = "Fehler beim Speichern."
            haml :page_edit
          end
        else
          if params[:for_person]
            redirect "/people/#{@target.id}"
          else
            redirect "/courses"
          end
        end
      end
      
      post '/pages/:id' do
        authenticate!
        @page = Page.find(params[:id])
        @page.write_attributes params[:page]
        @page.author = current_user
        
        if @page.save
          flash[:notice] = "Seite aktualisiert."
          if @page.person
            redirect "/people/#{@page.person.id}"
          else
            redirect "/courses"
          end
        else
          flash.now[:error] = "Fehler beim Speichern."
          raise @page.errors.inspect
          haml :page_edit
        end
      end
    end
  end
end