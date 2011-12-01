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
  end
end