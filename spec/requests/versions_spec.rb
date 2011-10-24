require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Versions" do
  let(:jonas) do
    Person.create! name: 'Jonas' do |u|
      u.uid = "schneijo"
    end
  end
  
  before :each do
    login(jonas.uid, jonas.name)
  end
  
  describe "visiting /people/:uid/page/versions" do
    describe "when there is a page" do
      let(:text) { 'Ohai' }
      before :each do
        jonas.create_page author: jonas, lks: text
        jonas.save!
        jonas.page.versions.length.should == 0
      end
      
      it 'shows the recent version' do
        get "/people/#{jonas.uid}/page/versions"
        last_response.body.should include(text)
      end
      
      describe "with multiple versions" do
        let(:new_text) { 'Neuer Text'}
        
        before :each do
          jonas.page.update_attributes lks: new_text
        end
        
        it 'shows a change' do
          get "/people/#{jonas.uid}/page/versions"
          last_response.body.should include(text)
          last_response.body.should include(new_text)
        end
      end
    end
  end
end