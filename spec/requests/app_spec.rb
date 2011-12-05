require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "The app" do
  let(:jonas) do
    Person.create! name: "Jonas Schneider" do |p|
      p.uid = "schneijo"
    end
  end
  
  let(:lukas) do
    Person.create! name: "Lukas" do |p|
      p.uid = "kramerlu"
    end
  end
  
  let(:anna) do
    Person.create!(name: "Anna") do |anna|
      anna.uid = "winteran"
      anna.bio = 'Bla'
      anna.lks = "ENDLICH!"
    end.tap do |anna|
      anna.create_page text: 'Text', author: jonas
    end
  end
  
  describe "'s API endpoint" do
    let(:key) { 'secret' }
    
    describe "without a proper key" do
      it "is inaccessible" do
        get '/api/people.json', :key => key
        last_response.status.should == 403
      end
    end
    
    describe "with a valid key" do
      before :all do
        app.set :api_key, key
      end
      
      it 'returns [] without any people' do
        get '/api/people.json', :key => key
        last_response.status.should == 200
        last_response.body.should == '[]'
      end
      
      it 'returns something when there are people' do
        jonas.tags.create name: 'test', author: lukas
        jonas.save!
        
        get '/api/people.json', :key => key
        
        last_response.status.should == 200
        last_response.body.should_not == '[]'
      end
    
      describe "GET /api/courses.json?key=<key>" do
        it 'returns [] without any courses' do
          get '/api/courses.json', :key => key
          last_response.status.should == 200
          last_response.body.should == '[]'
        end
        
        it 'returns something when there are courses' do
          Course.create! name: '4Bi01'
          
          get '/api/courses.json', :key => key
          
          last_response.status.should == 200
          last_response.body.should_not == '[]'
        end
      end
    end
  end
  
  describe "viewed as lukas" do
    before :each do
      login(lukas.uid, lukas.name)
    end
    
    describe "visiting /current_pdf" do
      it "redirects to the viewer url with a signature" do
        secret = 'totally sekret'
        ENV["PDF_VIEWER_SECRET"] = secret
        
        get '/current_pdf'
        u = URI.parse(last_response.headers["Location"])
        params = Rack::Utils.parse_query(u.query)
        
        u.host.should == "abitex.0x83.eu"
        u.path.should == "/"
        params["timestamp"].to_i.should be_within(5).of(Time.now.to_i)
        sig = OpenSSL::HMAC.hexdigest('sha1', secret, params["timestamp"])
        params["timestamp_sig"].should == sig
      end
    end
    
    describe "visiting /" do
      before :each do
        get "/"
      end
      
      describe "when the user has an email address set" do
        before :each do
          lukas.email = 'a@b.net'
          lukas.save!
          get "/"
        end
        
        it "shows no banner" do
          last_response.body.should_not have_selector("#nomail")
        end
      end
      
      it "shows a banner informing to enter an email address" do
        last_response.body.should have_selector("#nomail")
      end
      
      it "shows a link to the user's profile" do
        last_response.body.should have_selector("a[href='/people/#{lukas.uid}']")
      end
      
      it "shows a link to logout" do
        last_response.body.should have_selector("a[href='/logout']")
      end
      
      it "shows a link to the user's preferences" do
        last_response.body.should have_selector("a[href='/preferences']")
      end
      
      it "shows a link to the current PDF" do
        last_response.body.should have_selector("a[href='/current_pdf']")
      end
      
      it "shows a form to chat" do
        last_response.should have_selector 'form[action="/messages"][method=post] input[name="message[body]"]'
      end
      
      it "shows the last chat messages" do
        Message.create author: lukas, body: 'hai there'
        get "/"
        last_response.body.should include('hai there')
      end
    end
    
    describe "POSTing to /messages" do
      it "creates a message" do
        post '/messages', message: { body: 'Hai' }
        Message.first.author.should == lukas
        Message.first.body.should == 'Hai'
      end
      
      it "pushes" do
        Pusher['chat'].should_receive(:trigger)
        post '/messages', message: { body: 'Hai' }
      end
    end
    
    
    describe "visiting /courses" do
      let(:course) { Course.create! name: '4BIO02' }
      
      before :each do
        course
        get "/courses"
      end

      it "shows a link to the course page" do
        last_response.body.should have_selector "a[href='/courses/#{course.id}']"
      end
    end
    
    describe "visiting /courses/<id>" do
      let(:course) { Course.create! name: '4Bi2' }
      
      before :each do
        get "/courses/#{course.id}"
      end
      
      it "shows the course name" do
        last_response.body.should include(course.name)
      end
      
      it "shows a link to create a page for the course" do
        last_response.body.should have_selector "a[href='/pages/new?for_course=#{course.id}']"
      end
      
      describe "when the course has a page" do
        let(:page) { Page.create! text: 'bla', author: jonas }
        
        before :each do
          course.page = page
          course.save!
          get "/courses/#{course.id}"
        end
        
        it "shows the page content" do
          last_response.body.should include(page.text)
        end
        
        it "shows a link to edit the page" do
          last_response.body.should have_selector "a[href='/pages/#{page.id}/edit']"
        end
      end
    end
    
    describe "visiting /people/<uid>" do
      describe "when trying to visit one's own page" do
        before :each do
          lukas.create_page text: 'bla', author: jonas
          get "/people/#{lukas.uid}"
        end
        
        it "does not show the page contents"  do
          last_response.body.should_not include("bla")
        end
        
        it "shows a notice" do
          last_response.body.should include("deine eigene Seite nicht")
        end
        
        it 'displays no link to edit the page' do
          last_response.body.should_not have_selector("a[href='/pages/#{lukas.page.id}/edit']")
        end
      end
      
      describe "when the person has a page" do
        before :each do
          get "/people/#{anna.uid}"
        end
        
        it "displays the page info" do
          last_response.body.should include(anna.bio)
          last_response.body.should include(anna.lks)
          last_response.body.should include(anna.page.text)
        end
        
        it "renders the text as markdown" do
          anna.page.text = '*mytext*'
          anna.page.save!
          anna.save!
          get "/people/winteran"
          last_response.body.should have_selector('em', content: 'mytext')
        end
        
        it "displays the author's name" do
          last_response.body.should have_selector('#last-edit .user_name', :content => jonas.name)
        end
        
        it 'displays a link to edit the page' do
          last_response.body.should have_selector("a[href='/pages/#{anna.page.id}/edit']")
        end
        
        it 'displays a link to view the page versions' do
          last_response.body.should have_selector("a[href='/pages/#{anna.page.id}/versions']")
        end
      end
      
      describe "when the person does not yet have a page" do
        before :each do
          get "/people/#{jonas.id}"
        end
        
        it "shows a link to create the page" do
          last_response.body.should have_selector("a[href='/pages/new?for_person=schneijo']")
        end
        
        it 'displays a form to add a tag' do
          last_response.body.should have_selector("form[action='/people/schneijo/tags'][method=post] input[name='tag[name]']")
          fill_in 'tag[name]', with: 'test'
          click_button "Hinzufügen"
          
          last_response.headers["Location"].should == "http://example.org/people/schneijo"
          jonas.reload.tags.first.name.should == 'test'
          jonas.reload.tags.first.author.should == lukas
        end
        
        describe "but some tags" do
          it "displays the tag" do
            jonas.reload.tags.create name: 'test', author: lukas
            jonas.save!
            get "/people/#{jonas.id}"
            last_response.body.should have_selector('li.tag', content: 'test')
          end
        end
      end
    end
  end
end