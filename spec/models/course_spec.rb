require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Course" do
  let(:course) { Course.create! subject: 'bio', num: 4, teacher: 'Kunz', weekday: 3, creator: jonas }
  
  let(:jonas) do
    Person.create! name: "Jonas Schneider" do |p|
      p.uid = "schneijo"
    end
  end
  
  describe "#api_attributes" do
    it "works without a page" do
      course.api_attributes.should == {
        "fach" => 'Biologie',
        "weekday" => 'Donnerstag',
        "num" => 4,
        "lehrer" => "Kunz",
        
        "foto" => "http://image.shutterstock.com/display_pic_with_logo/195/195,1159450466,2/stock-vector-group-of-people-vector-1914678.jpg",
        
        "tags" => [],

        "text" => "",
        "author" => ""
      }
    end
    
    it "works with a page" do
      course.page = Page.create text: 'ohai', author: jonas
      
      course.api_attributes["text"].should == "ohai"
      course.api_attributes["author"].should ==  "Jonas Schneider"
    end
  end
  
  it "is valid" do
    course.should be_valid
  end
  
  it "has a page" do
    p = Page.new
    course.page = p
    course.page_id.should == p.id
  end
end