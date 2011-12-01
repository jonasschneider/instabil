require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Poll" do
  let(:me) { Person.create! name: 'Jonas' do |p| p.uid = 'schneijo'; end }
  let(:somebody) { Person.create! name: 'Lukas' do |p| p.uid = 'kramerlu'; end }
  
  let(:poll) { Poll.create! title: 'Meine Umfrage', creator: me }
  
  let(:answer) { poll.answers.create name: "Ich bin cool" }
  let(:another_answer) { poll.answers.create name: "Hey there" }
  
  
  it "starts out empty" do
    poll.answers.should be_empty
    poll.votes.should be_empty
    
    answer.vote_count.should == 0
  end
  
  describe "#vote_for(user)" do
    it "returns the vote" do
      poll.vote_for(me).answer.should == nil
      poll.cast_vote! me, answer
      poll.vote_for(me).answer.should == answer
    end
  end
  
  describe "#end_date=" do
    it "accepts jquery-formatted dates" do
      poll.end_date = '11/14/2011'
      poll.end_date.should == Date.new(2011, 11, 14)
    end
  end
  
  describe "#popularity" do
    it "returns an index of popularity based on number of votes and answers" do
      poll.cast_vote! me, answer
      poll.popularity.should > Poll.new.popularity
    end
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
  
  describe "with serious set to true" do
    let(:end_date) { Time.now+1.days }
    
    before :each do
      poll.serious = true
      poll.end_date = end_date
      poll.save!
    end
    
    it "requires an end date" do
      poll.end_date = nil
      answer.should_not be_valid
    end
    
    it "invalidates answers that are not created by the poll's creator" do
      answer = poll.answers.build name: 'Test', creator: somebody
      answer.should_not be_valid
    end
    
    describe "#cast_vote!(user, answer)" do
      it "creates a vote" do
        poll.cast_vote! me, answer
        
        poll.votes.length.should == 1
        answer.vote_count.should == 1
      end
      
      it "raises when trying to vote again" do
        poll.cast_vote! me, answer
        
        lambda do
          poll.cast_vote! me, another_answer
        end.should raise_error
      end
    
      it "raises when voting after the end date" do
        Timecop.travel(end_date+2.days) do
          lambda do
            poll.cast_vote! me, answer
          end.should raise_error
        end
      end
    end
  end
end