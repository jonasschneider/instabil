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
  
  let(:avatar_path) { File.join(File.dirname(__FILE__), '..', 'avatar.jpg') }

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
        jonas
        
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
    
    describe "visiting /preferences" do
      it "shows a form for the user to edit name and email" do
        lukas.update_attributes(name: 'Asdfname', email: 'test@example.com')
        lukas.save!
        get "/preferences"
        form = "form[action='/preferences'][method=post]"
        last_response.should have_selector form
        last_response.should have_selector form + ' input[name="person[name]"][type=text][value=Asdfname]'
        last_response.should have_selector form + ' input[name="person[email]"][type=text][value="test@example.com"]'
        last_response.should have_selector form + ' input[type=submit]'
        
        last_response.should have_selector form + ' input[name="person[kurs]"][type=text]'
        last_response.should have_selector form + ' input[name="person[g8]"][type=checkbox]'
        last_response.should have_selector form + ' input[name="person[bio]"][type=text]'
        
        last_response.should have_selector form + ' input[name="person[avatar]"][type=file]'
        
        last_response.should have_selector 'img[src="/people/kramerlu/avatar/medium"]'
      end
    end
    
    describe "visiting /people/<uid>/avatar/original" do
      it "displays the avatar image by default" do
        get "/people/kramerlu/avatar/original"
        last_response.body.length.should == File.size(File.join(File.dirname(__FILE__), '../../app/public/images/avatar.jpg'))
      end
      
      it "displays the user's avatar" do
        lukas.avatar = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
        lukas.save!
        get "/people/kramerlu/avatar/original"
        last_response.body.length.should == File.size(avatar_path)
      end
    end
    
    describe "visiting /people/<uid>/avatar/medium" do
      it "displays the user's avatar" do
        lukas.avatar = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
        lukas.save!
        get "/people/kramerlu/avatar/medium"
        last_response.body.length.should == lukas.avatar.to_file(:medium).size
      end
    end
    
    describe "POSTing to /preferences" do
      let(:new_name) { 'Laggas' }
      let(:new_email) { 'test@0x83.eu' }
      let(:old_uid) { lukas.uid }
      
      it "updates the users attributes" do
        old_uid
        post "/preferences", person: { name: new_name, email: new_email, bio: 'testing' }
        lukas.reload.name.should == new_name
        lukas.email.should == new_email
        lukas.uid.should == old_uid
        lukas.bio.should == 'testing'
      end
      
      describe "with an avatar" do
        it "updates the avatar" do
          f = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
          post "/preferences", person: { avatar: f }
          lukas.reload
          lukas.avatar.original_filename.should == 'avatar.jpg'
          lukas.avatar.to_file.length.should == File.size(avatar_path)
        end
        
        it "requires an image" do
          f = Rack::Test::UploadedFile.new(__FILE__, 'app_spec.rb')
          post "/preferences", person: { avatar: f }
          lukas.reload
          lukas.avatar.original_filename.should_not == 'app_spec.rb'
        end
      end
      
      describe "with a bogus email" do
        let(:new_email) { 'test0x83.eu' }
        
        it "updates the users attributes" do
          old_uid
          post "/preferences", person: { name: new_name, email: new_email, bio: 'testing' }
          lukas.email.should_not == new_email
          last_response.body.should include('Fehler')
        end
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
          get "/people/#{anna.uid}"
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
        it "shows a link to create the page" do
          get "/people/#{jonas.uid}"
          last_response.body.should have_selector("a[href='/pages/new?for_person=#{jonas.id}']")
        end
      end
    end
  end
end