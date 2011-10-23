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
      last_response.body.should include(name)
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
end

describe "The app" do
  let(:jonas) { Person.create! name: "Jonas Schneider", uid: "schneijo" }
  let(:lukas) { Person.create! name: "Lukas", uid: "kramerlu" }
  
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
    
    describe "visiting /people/<uid>/page" do
      describe "when the person has a page" do
        let(:anna) do
          Person.create!(name: "Anna", uid: "winteran").tap do |anna|
            anna.create_page bio: 'Ich halt.', lks: 'Musik', author: jonas
          end
        end
        
        it "displays the page info" do
          get "/people/#{anna.uid}/page"
          last_response.body.should include(anna.page.bio)
          last_response.body.should include(anna.page.lks)
        end
        
        it "displays the author's name" do
          get "/people/#{anna.uid}/page"
          last_response.body.should have_selector('#last-edit .user_name', :content => jonas.name)
        end
      end
      
      describe "when the person does not yet have a page" do
        it "redirects to the edit page" do
          get "/people/#{jonas.uid}/page"
          last_response.status.should == 302
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
    end
  end
end