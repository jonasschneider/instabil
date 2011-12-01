require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Authentication" do
  let(:user) { 'atmos' }
  let(:name) { 'Atmos' }
  let(:correct_id) { app.settings.authorized_group_id }

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
  
  describe 'GET /logout' do
    before :each do
      get '/logout'
    end
    
    it 'redirects to the fichteID logout page' do
      last_response.headers["Location"].should == 'http://fichteid.heroku.com/sso/logout'
    end
    
    it "clears the session"
  end
end