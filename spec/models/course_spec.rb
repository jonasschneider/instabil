require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Course" do
  let(:course) { Course.create! name: '4Bi2' }
  
  it "is valid" do
    course.should be_valid
  end
end