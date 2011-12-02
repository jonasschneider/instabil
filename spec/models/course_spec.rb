require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Course" do
  let(:course) { Course.create! name: '4Bi2' }
  
  it "is valid" do
    course.should be_valid
  end
  
  it "has a page" do
    p = Page.new
    course.page = p
    course.page_id.should == p.id
  end
end