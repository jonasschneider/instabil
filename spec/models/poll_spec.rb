require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Poll" do
  let(:me) { Person.create! name: 'Jonas' do |p| p.uid = 'schneijo'; end }
  let(:poll) { Poll.create! name: 'Meine Umfrage', creator: me }
  
  let(:answer) { poll.answers.create name: "Ich bin cool" }
  let(:another_answer) { poll.answers.create name: "Hey there" }
  
  
  it "starts out empty" do
    poll.answers.should be_empty
    poll.votes.should be_empty
    
    answer.vote_count.should == 0
  end
  
  describe "#cast_vote!(user, answer)" do
    it "creates a vote" do
      poll.cast_vote! me, answer
      
      poll.votes.length.should == 1
      answer.vote_count.should == 1
    end
    
    it "does not create duplicates" do
      poll.cast_vote! me, answer
      poll.cast_vote! me, answer
      
      poll.votes.length.should == 1
      answer.vote_count.should == 1
    end
    
    it "changes a vote" do
      poll.cast_vote! me, answer
      poll.cast_vote! me, another_answer
      
      poll.votes.length.should == 1
      answer.vote_count.should == 0
      another_answer.vote_count.should == 1
    end
  end
  
  describe "#vote_for(user)" do
    it "returns the vote" do
      poll.vote_for(me).answer.should == nil
      poll.cast_vote! me, answer
      poll.vote_for(me).answer.should == answer
    end
  end
end