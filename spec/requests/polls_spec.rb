require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Polls" do
  let(:lukas) do
    Person.create! name: "Lukas" do |p|
      p.uid = "kramerlu"
    end
  end
  let(:me) do
    Person.create! name: "Jonas" do |p|
      p.uid = "schneijo"
    end
  end
  
  before :each do
    login(lukas.uid, lukas.name)
  end

  describe 'on GET to /polls' do
    describe "with a poll" do
      let(:title) { "Meine Umfrage" }
      
      before :each do
        Poll.create! title: title, creator: lukas
      end
      
      it 'displays a list of polls' do
        get '/polls'
        last_response.body.should include(title)
      end
      
      it 'displays a form to create a poll' do
        get '/polls'
        form = "form[action='/polls'][method=post]"
        last_response.should have_selector form
        last_response.should have_selector form + ' input[name="poll[title]"][type=text]'
        last_response.should have_selector form + ' input[name="poll[serious]"][type=checkbox]'
        last_response.should have_selector form + ' input[name="poll[end_date]"][type=text]'
      end
    end
  end
  
  describe 'POST /polls' do
    it "creates a poll" do
      post '/polls', poll: { title: 'Ohai', serious: 'false', end_date: '' }
      last_response.headers["Location"].should == "http://example.org/polls/#{Poll.first.id}"
      p = Poll.first
      p.title.should == 'Ohai'
      p.creator.should == lukas
    end
    
    it "creates a serious poll" do
      post '/polls', poll: { title: 'Ohai', serious: true, end_date: '11/01/2011' }
      last_response.headers["Location"].should == "http://example.org/polls/#{Poll.first.id}"
      p = Poll.first
      p.title.should == 'Ohai'
      p.creator.should == lukas
      p.end_date.should == Date.new(2011, 11, 1)
    end
  end
  
  describe 'GET /polls/<id>' do
    let(:poll) { Poll.create title: 'Meine Umfrage', creator: lukas }
    
    before :each do
      get "/polls/#{poll.id}"
    end
    
    it "shows the title" do
      last_response.body.should include('Meine Umfrage')
    end
    
    it "shows the answers" do
      poll.answers.create name: 'Nein.', creator: lukas
      get "/polls/#{poll.id}"
      last_response.body.should include('Nein.')
      last_response.body.should have_selector '.votes', content: '0'
    end
    
    it "shows a button to vote for an answer" do
      a = poll.answers.create name: 'Ja', creator: lukas
      b = poll.answers.create name: 'Nein', creator: lukas
      get "/polls/#{poll.id}"
      
      form = "form[action='/polls/#{poll.id}/vote'][method=post]"
      last_response.should have_selector form + " input[name='vote[answer_id]'][value='#{a.id}']"
      last_response.should have_selector form + " input[name='vote[answer_id]'][value='#{b.id}']"
      
      #last_response.should have_selector form + " input[name='vote[answer_id]']', content: a.id.to_s
    end
    
    it "shows a form to add an answer" do
      form = "form[action='/polls/#{poll.id}/answers'][method=post]"
      last_response.should have_selector form
      last_response.should have_selector form + ' input[name="answer[name]"][type=text]'
    end
    
    it "does not mention the poll being serious" do
      last_response.body.should_not include('Abstimmung')
    end
    
    describe "with a serious poll" do
      let(:answer) { poll.answers.create name: 'Ja', creator: lukas }
      
      before :each do
        answer
        poll.end_date = Date.today + 2
        poll.serious = true
        poll.save!
      end
      
      it "shows the fact that this is a serious poll" do
        get "/polls/#{poll.id}"
        last_response.body.should include('Abstimmung')
      end
      
      it "only shows the answer creation to the poll creator" do
        login(lukas.uid, lukas.name)
        get "/polls/#{poll.id}"
        last_response.should have_selector 'input[name="answer[name]"][type=text]'
        
        login(me.uid, me.name)
        get "/polls/#{poll.id}"
        last_response.should_not have_selector 'input[name="answer[name]"][type=text]'
      end
      
      it "allows voting" do
        get "/polls/#{poll.id}"
        
        last_response.should have_selector "form[action='/polls/#{poll.id}/vote']"
      end
      
      describe "when the user has already voted" do
        before :each do
          poll.cast_vote! lukas, answer
        end
        
        it "does not allow voting" do
          get "/polls/#{poll.id}"
          
          last_response.should_not have_selector "form[action='/polls/#{poll.id}/vote']"
        end
      end
      
      describe "when the poll has ended" do
        before :each do
          poll.end_date = Date.today - 2
          poll.save!
        end
        
        it "does not allow voting" do
          get "/polls/#{poll.id}"
          
          last_response.should_not have_selector "form[action='/polls/#{poll.id}/vote']"
        end
      end
    end
  end
  
  describe 'POST /polls/<id>/vote' do
    let(:poll) { Poll.create title: 'Meine Umfrage', creator: lukas }
    let(:answer) { poll.answers.create name: 'Ja', creator: lukas }
    
    it "casts a vote" do
      post "/polls/#{poll.id}/vote", vote: { answer_id: answer.id }
      poll.reload.vote_for(lukas).should_not be_nil
      poll.reload.answers.first.vote_count.should == 1
    end
  end
  
  describe 'POST /polls/<id>/answers' do
    let(:poll) { Poll.create title: 'Meine Umfrage', creator: lukas }
    
    it "creates an answer" do
      post "/polls/#{poll.id}/answers", answer: { name: 'Nein.' }
      last_response.headers["Location"].should == "http://example.org/polls/#{Poll.first.id}"
      p = Poll.first
      p.answers.length.should == 1
      p.answers.first.name.should == 'Nein.'
      p.answers.first.creator.should == lukas
    end
  end
end