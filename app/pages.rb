module Instabil::Pages
  def self.registered(app)
    app.class_eval do
      get '/pages/:id/edit' do
        authenticate!
        @page = Page.find(params[:id])
        enforce_update_permission(@page)
        haml :page_edit
      end
      
      get '/pages/new' do
        authenticate!
        @page = Page.new
        enforce_create_permission(@page)
        @target = params[:for_person] ? Person.find(params[:for_person]) : Course.find(params[:for_course])
        haml :page_new
      end
      
      post '/pages' do
        authenticate!
        
        @target = params[:for_person] ? Person.find(params[:for_person]) : Course.find(params[:for_course])
        @page = Page.new
        @page.write_attributes params[:page]
        enforce_create_permission(@page)
        @page.author = current_user
        
        if @target.page.nil?
          if @page.save
            @target.page = @page
            @target.save!
            
            flash[:notice] = "Seite erstellt."
            if params[:for_person]
              redirect "/people/#{@target.id}"
            else
              redirect "/courses/#{@target.id}"
            end
          else
            flash.now[:error] = "Fehler beim Speichern."
            haml :page_edit
          end
        else
          if params[:for_person]
            redirect "/people/#{@target.id}"
          else
            redirect "/courses/#{@target.id}"
          end
        end
      end
      
      post '/pages/:id' do
        authenticate!
        @page = Page.find(params[:id])
        enforce_update_permission(@page)
        @page.write_attributes params[:page]
        @page.author = current_user
        
        if @page.save
          flash[:notice] = "Seite aktualisiert."
          if @page.person
            redirect "/people/#{@page.person.id}"
          else
            redirect "/courses/#{@page.course.id}"
          end
        else
          flash.now[:error] = "Fehler beim Speichern."
          raise @page.errors.inspect
          haml :page_edit
        end
      end
      
      get '/pages/:id/versions' do
        authenticate!
        @page = Page.find(params[:id])
        enforce_view_permission(@page)
        @versions = @page.versions
        
        haml :versions
      end

      post '/pages/:id/signoff' do
        authenticate!
        halt 403 unless current_user.moderator?
        @page = Page.find(params[:id])

        @page.signed_off_by ||= current_user
        @page.save!

        haml :page_edit
      end

      post '/pages/:id/un_signoff' do
        authenticate!
        halt 403 unless current_user.moderator?
        @page = Page.find(params[:id])

        @page.signed_off_by = nil
        @page.save!

        haml :page_edit
      end
    end
  end
end