require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Person" do
  let(:jonas) do
     p = Person.new name: "Jonas Schneider" do |me|
       me.uid = "schneijo"
     end
     p.tap do |p|
       p.save!
     end
  end
  let(:page) { jonas.create_page kurs: 5, g8: true, author: jonas }
  
  describe "#api_attributes" do
    it "returns a hash of attributes" do
      jonas.api_attributes['name'].should == "Jonas Schneider"
      jonas.api_attributes['uid'].should == "schneijo"
      jonas.api_attributes['email'].should == nil
    end
    
    it "returns the page's attributes when they are set" do
      page
      jonas.api_attributes['page']['kurs'].should == 5
      jonas.api_attributes['page']['g8'].should == 1
      jonas.api_attributes['page']['bio'].should == nil
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
  
  def stringify_keys hash
    hash.keys.each do |key|
      hash[key.to_s] = hash.delete(key)
    end
    hash
  end
end