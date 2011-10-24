require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Person" do
  let(:jonas) do
     Person.new name: "Jonas Schneider" do |me|
       me.uid = "schneijo"
     end
  end
  
  describe "#api_attributes" do
    it "returns a hash of attributes" do
      jonas.api_attributes['name'].should == "Jonas Schneider"
      jonas.api_attributes['uid'].should == "schneijo"
      jonas.api_attributes['email'].should == nil
    end
    
    it "returns the page's attributes when they are set" do
      jonas.page = { kurs: 5, g8: true }
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
  
  def stringify_keys hash
    hash.keys.each do |key|
      hash[key.to_s] = hash.delete(key)
    end
    hash
  end
end