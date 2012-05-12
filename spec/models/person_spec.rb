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

  describe "#meta_complete?" do
    it "returns true only when all fields are filled out" do
      jonas.meta_complete?.should == false
      jonas.lks = 'asdf'
      jonas.zukunft = 'asdf'
      jonas.nachabi = 'asdf'
      jonas.lebenswichtig = 'asdf'

      jonas.meta_complete?.should == false

      jonas.nachruf = 'asdf'
      jonas.meta_complete?.should == true
    end
  end

  describe "#tag_length" do
    it "returns the total length of all tags plus space for separator" do
      jonas.tags.create name: 'asdf', author: lukas
      jonas.tags.create name: 'lol', author: lukas
      jonas.tag_length.should == (7 + 3 * 2)
    end
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
    end
    
    it "returns the page text when set" do
      page
      jonas.api_attributes['page']['text'].should == 'asdf'
      jonas.api_attributes['page']['author'].should == 'Jonas Schneider'
    end

    it "returns the page text when set" do
      jonas.tags.create name: 'asdf', author: lukas
      jonas.tags.create name: 'asdf', author: lukas
      t1, t2 = jonas.tags.to_a
      jonas.api_attributes['page']['tags'].should == [[t1.name, t1.id.to_s], [t2.name, t2.id.to_s]]
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

  describe "avatar" do
    it "has a url" do
      jonas.avatar_url.should include("/people/schneijo/avatar")
    end

    it "fetches body and type from dropbox" do
      client = double()
      Person.stub(:dropbox_client) { client }

      client.should_receive(:get_file).with('/Abizeitung/people/avatar_thumbs/schneijo.jpg').and_return('ohai')
      jonas.avatar_body.should == 'ohai'
      jonas.avatar_type.should == 'image/jpg'
    end

    it "returns a nil body when the file does not exist" do
      client = double()
      Person.stub(:dropbox_client) { client }

      client.stub(:get_file) { raise DropboxError.new('a', 'b') }
      jonas.avatar_body.should == nil
    end

    it "deserializes the session from the environment" do
      require 'base64'
      ENV["DROPBOX_SESSION"] = Base64.encode64('ohai')
      DropboxSession.should_receive(:deserialize).with('ohai')
      Person.dropbox_session
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