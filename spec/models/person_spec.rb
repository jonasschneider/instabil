require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Person" do
  describe "#api_attributes" do
    it "returns a hash of attributes" do
      p = Person.new name: "Jonas Schneider", uid: "schneijo"#, page: { kurs: 5, g8: true }
      p.api_attributes['name'].should == "Jonas Schneider"
      p.api_attributes['uid'].should == "schneijo"
      p.api_attributes['email'].should == nil
    end
    
    it "returns the page's attributes when they are set" do
      p = Person.new name: "Jonas Schneider", uid: "schneijo", page: { kurs: 5, g8: true }
      p.api_attributes['page']['kurs'].should == 5
      p.api_attributes['page']['g8'].should == 1
      p.api_attributes['page']['bio'].should == nil
    end
  end
  
  def stringify_keys hash
    hash.keys.each do |key|
      hash[key.to_s] = hash.delete(key)
    end
    hash
  end
end