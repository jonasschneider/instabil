require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "The app" do
  let(:jonas) { make_person name: 'Jonas Schneider', uid: 'schneijo' }
  let(:lukas) { make_person name: 'Lukas', uid: 'kramerlu' }
  
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
        last_response.body.should_not have_selector("body.nomail")
      end
    end

    describe "shows a list of pages owned by the user" do
      before :each do
        jonas.create_page text: 'Text', author: lukas
        get "/"
      end
      
      it "works" do
        last_response.body.should have_selector("#dashboard a", content: 'Personenbericht für Jonas Schneider')
      end
    end
    
    it "shows a banner informing to enter an email address, and sets the email" do
      last_response.body.should have_selector("#nomail")
      last_response.body.should have_selector("body.nomail")
      lukas.zukunft = 'test'
      lukas.save!
      fill_in "person[email]", with: 'my@mail.net'
      click_button "Ja, die Email stimmt. Speichern!"
      lukas.reload
      lukas.email.should == 'my@mail.net'
      lukas.zukunft.should == 'test'
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
    
    it "shows the author of a person's page" do
      lukas.create_page text: 'asdf', author: jonas
      get "/"
      last_response.body.should have_selector('a[href="/people/kramerlu"] + *', content: '(Jonas Schneider schreibt die Seite)')
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
end