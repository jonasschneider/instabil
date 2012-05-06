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

  describe "visiting /people/<uid>/avatar" do
    it "displays the avatar image" do
      Person.any_instance.should_receive(:avatar_body).and_return('asdf')
      Person.any_instance.should_receive(:avatar_type).and_return('image/type')
      visit "/people/schneijo/avatar"
      last_response.body.should == 'asdf'
      last_response.content_type.should == 'image/type'
    end

    it "404's when the avatar body is nil" do
      Person.any_instance.should_receive(:avatar_body).and_return(nil)
      Person.any_instance.stub(:avatar_type) { 'image/type' }
      visit "/people/schneijo/avatar"
      last_response.status.should == 404
      last_response.content_type.should_not == 'image/type'
    end
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

      it "shows the avatar" do
        last_response.should have_selector 'img[src="'+jonas.avatar_url+'"]'
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
    end
  end
end