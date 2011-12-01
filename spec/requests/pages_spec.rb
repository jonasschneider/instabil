require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "The app" do
  let(:jonas) do
    Person.create! name: "Jonas Schneider" do |p|
      p.uid = "schneijo"
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
  
  before :each do
    login(jonas.uid, jonas.name)
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
        get "/people/#{jonas.uid}/page/edit"
        form = "form[action=\"/people/#{jonas.uid}/page\"][method=post]"
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
    describe "when the person has no page yet" do
      before :each do
        post "/people/#{jonas.uid}/page", { :page => { :kurs => '5' } }
      end
      
      it "creates the page with given attributes" do
        jonas.reload.page.kurs.should == 5
      end
      
      it "sets the page author" do
        jonas.reload.page.author.should == jonas
      end
    end
    
    describe "when the person already has a page" do
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
        anna.reload.page.author.should == jonas
      end
      
      it "versions the page" do
        anna.reload.page.version.should == 2
      end
    end
  end
end