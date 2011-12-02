require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Course" do
  let(:course) { Course.create! name: '4BI2' }
  
  it "returns the #group" do
    course.group.should == 'Bi (vierstündig)'
    course.name = '2INF05'
    course.group.should == 'Inf (zweistündig)'
    course.name = nil
    course.group.should == nil
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