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
  describe "logged in as atmos" do
    let(:user) { 'atmos' }
    let(:name) { 'Atmos' }
    
    before :each do
      login(user, name)
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