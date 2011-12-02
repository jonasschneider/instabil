require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Course" do
  let(:course) { Course.create! name: '4BI2' }
  
  it "#fach" do
    course.fach.should == 'Bi'
    course.name = '2INF05'
    course.fach.should == 'Inf'
    course.name = nil
    course.fach.should == nil
  end
  
  it "#num" do
    course.num.should == 4
    course.name = '2INF05'
    course.num.should == 2
    course.name = nil
    course.num.should == nil
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