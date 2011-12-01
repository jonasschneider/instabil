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
      anna.create_page text: 'Text', author: jonas
    end
  end
  
  let(:page) { anna.page }
  
  before :each do
    login(jonas.uid, jonas.name)
  end
  
  describe "visiting /pages/new?for_person=<uid>" do
    it "displays a form" do
      get "/pages/new?for_person=#{jonas.id}"
      form = "form[action=\"/pages\"][method=post]"
      last_response.should have_selector form
      last_response.should have_selector form + ' textarea[name="page[text]"]'
      last_response.should have_selector form + ' input[type=hidden][name=for_person][value=schneijo]'
      last_response.should have_selector form + ' input[type=submit]'
    end
  end

  describe "visiting /pages/:id/edit" do
    describe "when the page exists" do
      it "displays a form" do
        get "/pages/#{page.id}/edit"
        form = "form[action=\"/pages/#{page.id}\"][method=post]"
        last_response.should have_selector form
        last_response.should have_selector form + ' textarea[name="page[text]"]'
        last_response.should have_selector form + ' input[type=submit]'
      end
    end
  end
  
  
  describe "POSTing to /pages" do
    describe "when the person already has a page" do
      before :each do
        post "/pages", { :for_person => anna.id, :page => { :text => 'Entry-level' } }
      end
      
      it "does not create a page" do
        Page.last.text.should_not == 'Entry-level'
      end
      
      it "does not touch the person's page" do
        anna.page.should == anna.reload.page
      end
      
      it "redirects back to the person" do
        last_response.status.should == 302
        last_response.headers['Location'].should == "http://example.org/people/#{anna.id}"
      end
    end
    
    describe "when the person has no page yet" do
      before :each do
        post "/pages", { :for_person => jonas.id, :page => { :text => 'Entry-level' } }
      end
      
      it "creates a page with given text" do
        Page.last.text.should == 'Entry-level'
      end
      
      it "sets the person's page to the new one" do
        jonas.reload.page.should == Page.last
      end
      
      it "redirects back to the person" do
        last_response.status.should == 302
        last_response.headers['Location'].should == "http://example.org/people/#{jonas.id}"
      end
    end
  end
    
  
  describe "POSTing to /pages/:id" do
    describe "when the person already has a page" do
      before :each do
        post "/pages/#{anna.page.id}", { :page => { :text => 'Next-level' } }
      end
      
      it "redirects to the _person_ page (hacky)" do
        last_response.status.should == 302
        last_response.headers["Location"].should == 'http://example.org/people/winteran'
      end
      
      it "updates the page" do
        anna.page.reload.text.should == 'Next-level'
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