require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Instabil::Pages" do
  let(:jonas) do
    Person.create! name: "Jonas Schneider" do |p|
      p.uid = "schneijo"
    end
  end
  
  let(:lukas) { make_person name: "Lukas", uid: "kramerlu" }
  
  let(:anna) do
    Person.create!(name: "Anna") do |anna|
      anna.uid = "winteran"
    end.tap do |anna|
      anna.create_page text: 'Text', author: jonas
    end
  end
  
  
  before :each do
    login(jonas.uid, jonas.name)
  end
  
  describe "person pages" do
    let(:page) { anna.page }

    describe "signoff" do
      it "shows nothing as a normal user" do
        login(anna.uid, anna.name)
        get "/pages/#{page.id}/edit"
        last_response.body.should_not include('Als fertig markieren')
      end

      it "shows a button as moderator" do
        get "/pages/#{page.id}/edit"
        click_button 'Als fertig markieren'
        anna.reload.page.signed_off_by.should == jonas
        last_response.body.should include('Als fertig markiert von Jonas Schneider')
      end
    end
    
    describe "visiting /pages/new?for_person=<uid>" do
      it "displays a form" do
        get "/pages/new?for_person=#{anna.id}"
        
        last_response.body.should include("Anna")
        
        form = "form[action=\"/pages\"][method=post]"
        last_response.should have_selector form
        last_response.should have_selector form + ' textarea[name="page[text]"]'
        last_response.should have_selector form + ' input[type=hidden][name=for_person][value=winteran]'
        last_response.should have_selector form + ' input[type=submit]'
      end
    end
  
    describe "visiting /pages/:id/edit" do
      describe "when the page exists and was created by another user" do
        it "denies access" do
          login(lukas.uid, lukas.name)
          get "/pages/#{page.id}/edit"
          last_response.status.should == 403
        end
      end
      
      describe "when the page exists and was created by the current user" do
        it "displays a form" do
          get "/pages/#{page.id}/edit"
          form = "form[action=\"/pages/#{page.id}\"][method=post]"
          last_response.should have_selector form
          last_response.should have_selector form + ' textarea[name="page[text]"]'
          last_response.should have_selector form + ' input[type=submit]'
        end
      end
    end
    
    
    describe "POSTing to /pages" do
      describe "when the person already has a page" do
        before :each do
          post "/pages", { :for_person => anna.id, :page => { :text => 'Entry-level' } }
        end
        
        it "does not create a page" do
          Page.last.text.should_not == 'Entry-level'
        end
        
        it "does not touch the person's page" do
          anna.page.should == anna.reload.page
        end
        
        it "redirects back to the person" do
          last_response.status.should == 302
          last_response.headers['Location'].should == "http://example.org/people/#{anna.id}"
        end
      end
      
      describe "when the person has no page yet" do
        before :each do
          post "/pages", { :for_person => jonas.id, :page => { :text => 'Entry-level' } }
        end
        
        it "creates a page with given text" do
          Page.last.text.should == 'Entry-level'
        end
        
        it "sets the person's page to the new one" do
          jonas.reload.page.should == Page.last
        end
        
        it "redirects back to the person" do
          last_response.status.should == 302
          last_response.headers['Location'].should == "http://example.org/people/#{jonas.id}"
        end
      end
    end
      
    
    describe "POSTing to /pages/:id" do
      describe "when the person already has a page" do
        describe "authored by another user" do
          it "denies access" do
            login(lukas.uid, lukas.name)
            post "/pages/#{anna.page.id}", { :page => { :text => 'Next-level' } }
            last_response.status.should == 403
          end
        end
        
        before :each do
          post "/pages/#{anna.page.id}", { :page => { :text => 'Next-level' } }
        end
        
        it "redirects to the _person_ page (hacky)" do
          last_response.status.should == 302
          last_response.headers["Location"].should == 'http://example.org/people/winteran'
        end
        
        it "updates the page" do
          anna.page.reload.text.should == 'Next-level'
        end
        
        it "sets the page author" do
          anna.reload.page.author.should == jonas
        end
        
        it "versions the page" do
          anna.reload.page.version.should == 2
        end
      end
    end
  end
  
  describe "course pages" do
    let(:course) { Course.create! name: '4Bio1' }
    let(:page) { course.page = Page.create!(text: 'Ohai', author: jonas); course.save!; course.page }
    
    describe "visiting /pages/new?for_course=<course_id>" do
      it "displays a form" do
        get "/pages/new?for_course=#{course.id}"
        
        last_response.body.should include("4Bio1")
        
        form = "form[action=\"/pages\"][method=post]"
        last_response.should have_selector form
        last_response.should have_selector form + ' textarea[name="page[text]"]'
        last_response.should have_selector form + ' input[type=hidden][name=for_course][value="'+course.id.to_s+'"]'
        last_response.should have_selector form + ' input[type=submit]'
      end
    end
    
    describe "visiting /pages/:id/edit" do
      describe "when the page exists" do
        it "displays a form" do
          get "/pages/#{page.id}/edit"
          form = "form[action=\"/pages/#{page.id}\"][method=post]"
          last_response.should have_selector form
          last_response.should have_selector form + ' textarea[name="page[text]"]'
          last_response.should have_selector form + ' input[type=submit]'
        end
      end
    end
    
    
    describe "POSTing to /pages" do
      describe "when the course already has a page" do
        before :each do
          page
          post "/pages", { :for_course => course.id, :page => { :text => 'Entry-level' } }
        end
        
        it "does not create a page" do
          Page.last.text.should_not == 'Entry-level'
        end
        
        it "does not touch the course's page" do
          course.page.should == course.reload.page
        end
        
        it "redirects back to the course's page" do
          last_response.status.should == 302
          last_response.headers['Location'].should == "http://example.org/courses/#{course.id}"
        end
      end
      
      describe "when the course has no page yet" do
        before :each do
          post "/pages", { :for_course => course.id, :page => { :text => 'Entry-level' } }
        end
        
        it "creates a page with given text" do
          Page.last.text.should == 'Entry-level'
        end
        
        it "sets the course's page to the new one" do
          course.reload.page.should == Page.last
        end
        
        it "redirects back to the courses page" do
          last_response.status.should == 302
          last_response.headers['Location'].should == "http://example.org/courses/#{course.id}"
        end
      end
    end
      
    
    describe "POSTing to /pages/:id" do
      describe "when the course already has a page" do
        before :each do
          post "/pages/#{page.id}", { :page => { :text => 'Next-level' } }
        end
        
        it "redirects to the courses page" do
          last_response.status.should == 302
          last_response.headers["Location"].should == "http://example.org/courses/#{course.id}"
        end
        
        it "updates the page" do
          page.reload.text.should == 'Next-level'
        end
        
        it "sets the page author" do
          page.reload.author.should == jonas
        end
        
        it "versions the page" do
          page.reload.version.should == 2
        end
      end
    end
    
    describe "visiting /pages/:id/versions" do
      describe "when there is a page" do
        it 'shows the recent version' do
          get "/pages/#{page.id}/versions"
          last_response.body.should include(page.name)
        end
        
        describe "with multiple versions" do
          let(:new_text) { 'Neuer Text'}
          
          before :each do
            page.update_attributes lks: new_text
          end
          
          it 'shows a change' do
            get "/pages/#{page.id}/versions"
            last_response.body.should include(page.text)
            last_response.body.should include(new_text)
          end
        end
      end
    end
  end
  

  
end