require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Page" do
  let(:me) { Person.create! name: 'Jonas' do |p| p.uid = 'schneijo'; end }
  let(:page) { Page.create(kurs: 5, g8: true, author: me) }
  
  it "is valid" do
    page.should be_valid
    page.errors.should be_empty
  end
  
  describe "author" do
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
  
  describe "#compare" do
    it "works for the first version" do
      page.version.should == 1
      page.compare(0, 1).should == { "kurs" => 5, "g8" => true }
    end
    
    it "works for a second version" do
      page.update_attributes(kurs: 10)
      
      page.version.should == 2
      page.compare(1, 2).should == { "kurs" => 10 }
    end
  end
end