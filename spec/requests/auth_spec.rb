require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Authentication" do
  let(:user) { 'atmos' }
  let(:name) { 'Atmos' }
  let(:correct_id) { app.settings.authorized_group_id }
  
  describe "visiting / when not logged in" do
    it "displays an info page" do
      get '/'
      last_response.status.should == 200
    end
    
    it "displays a link to log in" do
      get '/'
      last_response.should have_selector("form[action='/auth/fichteid']")
    end
  end

  describe 'with the correct group id' do
    let(:group_ids) { "#{correct_id}" }
    
    it 'works' do
      post '/auth/developer/callback', :username => user, :name => name, :group_ids => group_ids
      last_response.headers['Location'].should == 'http://example.org/'
      follow_redirect!
      last_response.body.should include(name)
    end
    
    it "creates a person" do
      post '/auth/developer/callback', :username => user, :name => name, :group_ids => group_ids
      Person.first.uid.should == 'atmos'
      Person.first.name.should == 'Atmos'
      Person.first.original_name.should == 'Atmos'
      Person.first.email.should == nil
    end
  end
  
  describe 'with a set of groups including the correct group id' do
    let(:group_ids) { "#{correct_id+1},#{correct_id}" }
    
    it 'works' do
      post '/auth/developer/callback', :username => user, :name => name, :group_ids => group_ids
      last_response.headers['Location'].should == 'http://example.org/'
      follow_redirect!
      last_response.body.should include(name)
    end
  end
  
  describe 'with an unauthorized group id' do
    let(:group_ids) { "#{correct_id+1}" }
    
    it 'fails' do
      post '/auth/developer/callback', :username => user, :name => name, :group_ids => group_ids
      last_response.status.should == 403
      last_response.body.should include('nicht berechtigt')
    end
  end
  
  describe 'as a banned user, with the correct group id' do
    let(:group_ids) { "#{correct_id}" }
    
    it 'fails' do
      ENV["BANNED_UIDS"] = "someguy,#{user},anotherone"
      
      post '/auth/developer/callback', :username => user, :name => name, :group_ids => group_ids
      last_response.status.should == 403
      last_response.body.should include('nicht berechtigt')
    end
  end
  
  describe 'GET /logout' do
    describe "when logged in" do
      let(:lukas) do
        Person.create! name: "Lukas" do |p|
          p.uid = "kramerlu"
        end
      end
      
      before :each do
        login(lukas.uid, lukas.name)
        get '/logout'
      end
      
      it 'redirects to the fichteID logout page with a return_to parameter' do
        last_response.headers["Location"].should == 'http://fichteid.heroku.com/sso/logout?return_to=http://example.org/'
      end
      
      it "clears the session" do
        get '/courses'
        last_response.status.should == 301
      end
    end
  end
end