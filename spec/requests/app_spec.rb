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
    end.tap do |anna|
      anna.build_page bio: 'Ich halt.', lks: 'Musik', text: 'Text'
      anna.page.author = jonas
      anna.page.save!
    end
  end

  describe "'s API endpoint" do
    let(:key) { 'secret' }
    
    describe "without a proper key" do
      it "is inaccessible" do
        get '/api', :key => key
        last_response.status.should == 403
      end
    end
    
    describe "with a valid key" do
      before :all do
        app.set :api_key, key
      end
      
      it 'returns [] without any people' do
        get '/api', :key => key
        last_response.status.should == 200
        last_response.body.should == '[]'
      end
      
      it 'returns something when there are people' do
        jonas
        
        get '/api', :key => key
        
        last_response.status.should == 200
        last_response.body.should_not == '[]'
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
      
      it "shows a link to the user's profile" do
        last_response.body.should have_selector("a[href='/people/#{lukas.uid}']")
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
        last_response.should have_selector form + ' input[name="preferences[name]"][type=text][value=Asdfname]'
        last_response.should have_selector form + ' input[name="preferences[email]"][type=text][value="test@example.com"]'
        last_response.should have_selector form + ' input[type=submit]'
      end
    end
    
    describe "POSTing to /preferences" do
      let(:new_name) { 'Laggas' }
      let(:new_email) { 'test@0x83.eu' }
      let(:old_uid) { lukas.uid }
      
      it "updates the users name and email" do
        old_uid
        post "/preferences", preferences: { name: new_name, email: new_email }
        lukas.reload.name.should == new_name
        lukas.email.should == new_email
        lukas.uid.should == old_uid
      end
    end
    
    describe "visiting /people/<uid>" do
      describe "when the person has a page" do
        before :each do
          get "/people/#{anna.uid}"
        end
        
        it "displays the page info" do
          last_response.body.should include(anna.page.bio)
          last_response.body.should include(anna.page.lks)
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
          last_response.body.should have_selector("a[href='/people/#{anna.uid}/page/edit']")
        end
        
        it 'displays a link to view the page versions' do
          last_response.body.should have_selector("a[href='/people/#{anna.uid}/page/versions']")
        end
      end
      
      describe "when the person does not yet have a page" do
        it "shows a link to create the pge" do
          get "/people/#{jonas.uid}"
          last_response.body.should have_selector("a[href='/people/#{jonas.uid}/page/edit']")
        end
      end
    end

    describe "visiting /people/<uid>/page/edit" do
      describe "when the person exists" do
        it "displays a form" do
          get "/people/#{lukas.uid}/page/edit"
          form = "form[action=\"/people/#{lukas.uid}/page\"][method=post]"
          last_response.should have_selector form
          last_response.should have_selector form + ' input[name="page[kurs]"][type=text]'
          last_response.should have_selector form + ' input[name="page[g8]"][type=checkbox]'
          last_response.should have_selector form + ' input[name="page[bio]"][type=text]'
          last_response.should have_selector form + ' textarea[name="page[text]"]'
          last_response.should have_selector form + ' input[type=submit]'
        end
      end
    end
    
    describe "POSTing to /people/<uid>/page" do
      describe "when there is a matching person that has no page yet" do
        before :each do
          post "/people/#{jonas.uid}/page", { :page => { :kurs => '5' } }
        end
        
        it "creates the page with given attributes" do
          jonas.reload.page.kurs.should == 5
        end
        
        it "sets the page author" do
          jonas.reload.page.author.should == lukas
        end
      end
      
      describe "when there is a matching person that already has a page" do
        let(:new_bio) { 'Immer noch ich.' }
        
        before :each do
          post "/people/#{anna.uid}/page", { :page => { :bio => new_bio } }
        end
        
        it "redirects to the page" do
          last_response.status.should == 302
        end
        
        it "updates the page" do
          anna.reload.page.bio.should == new_bio
        end
        
        it "sets the page author" do
          anna.reload.page.author.should == lukas
        end
        
        it "versions the page" do
          anna.reload.page.version.should == 2
        end
      end
    end
  end
end