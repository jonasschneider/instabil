require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Polls" do
  let(:lukas) do
    Person.create! name: "Lukas" do |p|
      p.uid = "kramerlu"
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
      end
    end
  end
  
  describe 'POST /polls' do
    it "creates a poll" do
      post '/polls', poll: { title: 'Ohai' }
      last_response.headers["Location"].should == "http://example.org/polls/#{Poll.first.id}"
      p = Poll.first
      p.title.should == 'Ohai'
      p.creator.should == lukas
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
      poll.cast_vote! lukas, poll.answers.first
      get "/polls/#{poll.id}"
      last_response.body.should include('Nein.')
      last_response.body.should have_selector '.votes', content: '1'
    end
    
    it "shows a form to add an answer" do
      form = "form[action='/polls/#{poll.id}/answers'][method=post]"
      last_response.should have_selector form
      last_response.should have_selector form + ' input[name="answer[name]"][type=text]'
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