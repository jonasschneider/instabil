require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Page" do
  describe "author" do
    let(:name) { 'Jonas' }
    it "is printed with name in #api_attributes" do
      me = Person.new uid: 'schneijo', name: name
      p = Page.create! author: me
      p.api_attributes['author'].should == name
    end
  end
  
  describe "versioning" do
    it "creates new versions" do
      p = Page.create! kurs: 5, g8: true
      p.version.should == 1
      p.versions.length.should == 0
      
      p.kurs = 6
      
      p.save!
      
      p.versions.length.should == 1
      p.version.should == 2
      
      p.versions.first.kurs.should == 5
    end
  end
end