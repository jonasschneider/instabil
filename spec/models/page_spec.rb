require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Page" do
  let(:me) { Person.create! uid: 'schneijo', name: 'Jonas' }
  let(:page) { Page.create! kurs: 5, g8: true, author: me }
  
  describe "author" do
    it "is displayed by name in #api_attributes" do
      page.api_attributes['author'].should == 'Jonas'
    end
    
    it "is required" do
      p = Page.new
      p.should_not be_valid
      p.author = me
      p.should be_valid
    end
  end
  
  describe "versioning" do
    it "creates new versions" do
      page.version.should == 1
      page.versions.length.should == 0

      page.kurs = 6
      
      page.save!
      
      page.versions.length.should == 1
      page.version.should == 2
      
      page.versions.first.kurs.should == 5
    end
  end
end