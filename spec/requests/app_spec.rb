require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "authing" do
  let(:user) { 'atmos' }
  let(:name) { 'Atmos' }
  let(:correct_id) { app.settings.authorized_group_id }

  describe 'with the correct group id' do
    let(:group_ids) { "#{correct_id}" }
    
    it 'works' do
      post '/auth/developer/callback', :username => user, :name => name, :group_ids => group_ids
      last_response.headers['Location'].should == 'http://example.org/'
      follow_redirect!
      last_response.body.should have_selector('.user_name', :content => name)
    end
  end
  
  describe 'with a set of groups including the correct group id' do
    let(:group_ids) { "#{correct_id+1},#{correct_id}" }
    
    it 'works' do
      post '/auth/developer/callback', :username => user, :name => name, :group_ids => group_ids
      last_response.headers['Location'].should == 'http://example.org/'
      follow_redirect!
      last_response.body.should have_selector('.user_name', :content => name)
    end
  end
  
  describe 'with an unauthorized group id' do
    let(:group_ids) { "#{correct_id+1}" }
    
    it 'fails' do
      post '/auth/developer/callback', :username => user, :name => name, :group_ids => group_ids
      last_response.status.should == 403
      last_response.body.should =~ /nicht berechtigt/
    end
  end
end

describe "The app" do
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
        Person.create! name: "Jonas Schneider", uid: "schneijo", page: { kurs: 5, g8: true }
        
        get '/api', :key => key
        
        last_response.status.should == 200
        last_response.body.should_not == '[]'
      end
    end
  end
  
  describe "logged in as atmos" do
    let(:user) { 'atmos' }
    let(:name) { 'Atmos' }
    
    before :each do
      login(user, name)
    end
    
    describe "visiting /people/schneijo/page" do
      describe "when there is a matching person" do
        let(:bio) { 'Ich halt.' }
        let(:lks) { 'Chemie' }
        before :each do
          Person.create name: "Jonas S.", uid: "schneijo", page: { bio: bio, lks: lks }
        end
        
        it "displays the page info" do
          get '/people/schneijo/page'
          last_response.body.should =~ /#{bio}/
          last_response.body.should =~ /#{lks}/
        end
      end
    end

    describe "visiting /people/schneijo/page/edit" do
      describe "when there is a matching person" do
        before :each do
          Person.create :name => "Jonas S.", :uid => "schneijo"
        end
        
        it "displays a form" do
          get '/people/schneijo/page/edit'
          form = 'form[action="/people/schneijo/page"][method=post]'
          last_response.should have_selector form
          last_response.should have_selector form + ' input[name="page[kurs]"][type=text]'
          last_response.should have_selector form + ' input[name="page[g8]"][type=checkbox]'
          last_response.should have_selector form + ' input[name="page[bio]"][type=text]'
          last_response.should have_selector form + ' textarea[name="page[text]"]'
          last_response.should have_selector form + ' input[type=submit]'
        end
      end
    end
    
    describe "POSTing to /people/schneijo/page" do
      describe "when there is a matching person" do
        before :each do
          Person.create :name => "Jonas S.", :uid => "schneijo"
        end
        
        it "updates the attributes" do
          post '/people/schneijo/page', { :page => { :kurs => '5' } }
          Person.find('schneijo').page.kurs.should == 5
        end
      end
    end
    
  end
end