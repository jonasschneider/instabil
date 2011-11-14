require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Vote" do
  let(:me) { Person.create! name: 'Jonas' do |p| p.uid = 'schneijo'; end }
  let(:poll) { Poll.create! name: 'Meine Umfrage', creator: me }
  
  it "works" do
    poll.answers.should be_empty
    poll.votes.should be_empty
  end
end