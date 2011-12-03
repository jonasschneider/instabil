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
      jonas.api_attributes['page']['foto'].should == nil
    end
    
    it "returns the page text when set" do
      page
      jonas.api_attributes['page']['text'].should == 'asdf'
      jonas.api_attributes['page']['author'].should == 'Jonas Schneider'
    end
  end
  
  it "protects uid attribute" do
    lambda do
      jonas.write_attributes uid: 'troll'
    end.should_not change(jonas, :uid)
  end
  
  describe ".without_page" do
    it "works" do
      jonas
      Person.without_page.to_a.should == [jonas]
      page
      jonas.reload.save!
      Person.without_page.to_a.should == []
    end
  end
  
  describe ".with_page" do
    it "works" do
      jonas
      Person.with_page.to_a.should == []
      page
      jonas.reload.save!
      Person.with_page.to_a.should == [jonas]
    end
  end
  
  describe "avatar" do
    let(:avatar_path) { File.join(File.dirname(__FILE__), '..', 'avatar.jpg') }
    
    it "gets resized" do
      jonas.avatar = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
      jonas.save!
      x = Tempfile.new 'avatar'
      x.write(jonas.avatar.to_file(:medium).read)
      x.close
      `identify #{x.path}`.should include('300x300')
    end
  end
end