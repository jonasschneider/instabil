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
        last_response.body.should have_selector("a[href='/people/#{lukas.uid}/page']")
      end
      
      it "shows a link to the user's preferences" do
        last_response.body.should have_selector("a[href='/preferences']")
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
    
    describe "visiting /people/<uid>/page" do
      describe "when the person has a page" do
        let(:anna) do
          Person.create!(name: "Anna") do |anna|
            anna.uid = "winteran"
          end.tap do |anna|
            anna.build_page bio: 'Ich halt.', lks: 'Musik'
            anna.page.author = jonas
            anna.page.save!
          end
        end
        
        before :each do
          get "/people/#{anna.uid}/page"
        end
        
        it "displays the page info" do
          last_response.body.should include(anna.page.bio)
          last_response.body.should include(anna.page.lks)
        end
        
        it "displays the author's name" do
          last_response.body.should have_selector('#last-edit .user_name', :content => jonas.name)
        end
        
        it 'displays an edit button' do
          last_response.body.should have_selector("a[href='/people/#{anna.uid}/page/edit']")
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