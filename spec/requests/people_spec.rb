require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe Instabil::People do
  let(:jonas) { make_person name: 'Jonas Schneider', uid: 'schneijo' }
  let(:lukas) { make_person name: 'Lukas', uid: 'kramerlu' }
  
  let(:anna) do
    Person.create!(name: "Anna") do |anna|
      anna.uid = "winteran"
      anna.bio = 'Bla'
      anna.lks = "ENDLICH!"
    end.tap do |anna|
      anna.create_page text: 'Text', author: jonas
    end
  end
  
  before :each do
    login(lukas.uid, lukas.name)
  end
  
  describe "visiting /people/<uid>" do
    describe "when there is no such user" do
      before :each do
        get "/people/ohai"
      end
      
      it "404's" do
        last_response.status.should == 404
      end
    end
    
    describe "when trying to visit one's own page" do
      before :each do
        lukas.create_page text: 'bla', author: jonas
        get "/people/#{lukas.uid}"
      end
      
      it "does not show the page contents"  do
        last_response.body.should_not include("bla")
      end
      
      it "shows a notice" do
        last_response.body.should include("deine eigene Seite nicht")
      end
      
      it 'displays no link to edit the page' do
        last_response.body.should_not have_selector("a[href='/pages/#{lukas.page.id}/edit']")
      end
    end
    
    describe "when the person has a page" do
      before :each do
        get "/people/#{anna.uid}"
      end
      
      it "displays the page info" do
        last_response.body.should include(anna.bio)
        last_response.body.should include(anna.lks)
        last_response.body.should include(anna.page.text)
      end
      
      it "renders the text as markdown" do
        anna.page.text = '*mytext*'
        anna.page.save!
        anna.save!
        get "/people/winteran"
        last_response.body.should have_selector('em', content: 'mytext')
      end
      
      it "displays the author's name" do
        last_response.body.should have_selector('#last-edit .user_name', :content => jonas.name)
      end
      
      it 'displays a link to edit the page' do
        last_response.body.should have_selector("a[href='/pages/#{anna.page.id}/edit']")
      end
      
      it 'displays a link to view the page versions' do
        last_response.body.should have_selector("a[href='/pages/#{anna.page.id}/versions']")
      end
    end
    
    describe "when the person does not yet have a page" do
      before :each do
        get "/people/#{jonas.id}"
      end
      
      it "shows a link to create the page" do
        last_response.body.should have_selector("a[href='/pages/new?for_person=schneijo']")
      end
      
      it 'displays a form to add a tag' do
        last_response.body.should have_selector("form[action='/people/schneijo/tags'][method=post] input[name='tag[name]']")
        fill_in 'tag[name]', with: 'test'
        click_button "Hinzufügen"
        
        last_response.headers["Location"].should == "http://example.org/people/schneijo"
        jonas.reload.tags.first.name.should == 'test'
        jonas.reload.tags.first.author.should == lukas
      end
      
      describe "but some tags" do
        it "displays the tag" do
          jonas.reload.tags.create name: 'test', author: lukas
          jonas.save!
          get "/people/#{jonas.id}"
          last_response.body.should have_selector('li.tag', content: 'test')
        end
      end
    end
  end
end