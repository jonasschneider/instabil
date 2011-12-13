require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Person" do
  let(:jonas) do
     p = Person.new name: "Jonas Schneider" do |me|
       me.uid = "schneijo"
     end
     p.tap do |p|
       p.kurs = 5
       p.g8 = true
       p.lks = 'lks'
       p.save!
     end
  end
  
  let(:page) do
    jonas.create_page text: 'asdf', author: jonas
  end
  
  it "validate emails" do
    jonas.email = 'asdf'
    jonas.should_not be_valid
    jonas.email = 'a@b.net'
    jonas.should be_valid
  end
  
  describe "#api_attributes" do
    it "returns a hash of attributes" do
      jonas.api_attributes['uid'].should == "schneijo"
      jonas.api_attributes['email'].should == nil
      jonas.api_attributes['name'].should == "Jonas Schneider"
    end
    
    it "returns the page attributes" do
      jonas.api_attributes['page']['kurs'].should == 5
      jonas.api_attributes['page']['g8'].should == 1
      jonas.api_attributes['page']['lks'].should == 'lks'
      jonas.api_attributes['page']['bio'].should == nil
      jonas.api_attributes['page']['foto'].should == "/people/schneijo/avatar/medium"
    end
    
    it "returns the page text when set" do
      page
      jonas.api_attributes['page']['text'].should == 'asdf'
      jonas.api_attributes['page']['author'].should == 'Jonas Schneider'
    end
    
    it "g8 is 2 when nil" do
      jonas.api_attributes['page']['g8'].should == 1
      jonas.g8 = false
      jonas.api_attributes['page']['g8'].should == 0
      jonas.g8 = nil
      jonas.api_attributes['page']['g8'].should == 2
    end
  end
  
  it "protects uid attribute" do
    lambda do
      jonas.write_attributes uid: 'troll'
    end.should_not change(jonas, :uid)
  end
  
 describe "#zug" do
    it "works" do
      jonas.zug.should == 'G8'
      jonas.g8 = false
      jonas.zug.should == 'G9'
      jonas.g8 = nil
      jonas.zug.should == 'G8/G9?'
    end
  end
  
  describe "#avatar" do
    # see spec/requests/avatar_spec.rb, they need the ernie
  end
end