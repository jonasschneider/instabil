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
       p.zukunft = 'cool'
       p.save!
     end
  end

  let(:lukas) do
     Person.new name: "Lukas Kramer" do |me|
       me.uid = "kramerlu"
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
      jonas.api_attributes['page']['zukunft'].should == 'cool'
      jonas.api_attributes['page']['nachabi'].should == nil
      jonas.api_attributes['page']['lebenswichtig'].should == nil
      
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
    let(:avatar_path) { File.join(File.dirname(__FILE__), '..', 'avatar.jpg') }
    
    it "gets resized" do
      jonas.avatar = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
      jonas.save!
      x = Tempfile.new 'avatar'
      x.write(jonas.avatar.to_file(:medium).read)
      x.close
      `identify #{x.path}`.should include('300x300')
    end
  
    it "has a url" do
      jonas.avatar = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
      jonas.save!
      jonas.avatar_url.should include("/people/schneijo/avatar/original")
    end
  end

  describe "#assigned_pages" do
    it "returns [] when empty" do
      jonas.assigned_pages.should == []
    end

    it "returns the pages the user is author of" do
      page
      jonas.assigned_pages.should == [page]
    end
  end

  describe "#moderator?" do
    before do
      Person.moderator_uids = ['schneijo']
    end

    it "returns the right value" do
      jonas.moderator?.should == true
      lukas.moderator?.should == false
    end
  end
end