require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe Instabil::People do
  let(:jonas) { make_person name: 'Jonas Schneider', uid: 'schneijo' }
  let(:lukas) { make_person name: 'Lukas', uid: 'kramerlu' }

  let(:anna) do
    Person.create!(name: "Anna") do |anna|
      anna.uid = "winteran"
      anna.zukunft = 'Bla'
      anna.lks = "ENDLICH!"
    end.tap do |anna|
      anna.create_page text: 'annatext', author: jonas
    end
  end
  
  before :each do
    login(jonas.uid, jonas.name)
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
        jonas.create_page text: 'bla', author: lukas
        get "/people/#{jonas.uid}"
      end
      
      it "does show the page contents"  do
        last_response.body.should_not include("bla")
      end
      
      it "shows a notice" do
        last_response.body.should include("nicht anschauen")
      end
      
      it 'displays no link to edit the page' do
        last_response.body.should_not have_selector("a[href='/pages/#{jonas.page.id}/edit']")
      end
    end
    
    describe "when the person has a page" do
      before :each do
        get "/people/#{anna.uid}"
      end
      
      it "displays the page text" do
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
      
      it 'displays no link to create the page' do
        last_response.body.should_not have_selector("a[href='/pages/new?for_person=winteran']")
      end
      
      it 'displays a link to edit the page' do
        last_response.body.should have_selector("a[href='/pages/#{anna.page.id}/edit']")
      end
      
      describe "authored by someone else" do
        before do
          login(lukas.uid, lukas.name)
          get "/people/winteran"
        end

        it 'displays no link to edit the page' do
          last_response.body.should_not have_selector("a[href='/pages/#{anna.page.id}/edit']")
        end

        it "does not show the page contents"  do
          last_response.body.should_not include("annatext")
        end
        
        it "shows a notice" do
          last_response.body.should include("nicht anschauen")
        end
      end
      
      it 'displays a link to view the page versions' do
        last_response.body.should have_selector("a[href='/pages/#{anna.page.id}/versions']")
      end
    end
    
    describe "when the person does not yet have a page" do
      before :each do
        get "/people/#{lukas.id}"
      end
      
      it "shows a link to create the page" do
        last_response.body.should have_selector("a[href='/pages/new?for_person=kramerlu']")
      end
      
      it 'displays a form to add a tag' do
        last_response.body.should have_selector("form[action='/people/kramerlu/tags'][method=post] input[name='tag[name]']")
        fill_in 'tag[name]', with: 'test'
        click_button "Hinzufügen"
        
        last_response.headers["Location"].should == "http://example.org/people/kramerlu"
        lukas.reload.tags.first.name.should == 'test'
        lukas.reload.tags.first.author.should == jonas
      end
      
      describe "but some tags" do
        it "displays the tag" do
          lukas.reload.tags.create name: 'test', author: jonas
          lukas.save!
          get "/people/#{lukas.id}"
          last_response.body.should have_selector('li.tag', content: 'test')
        end
      end
    end
  end
end