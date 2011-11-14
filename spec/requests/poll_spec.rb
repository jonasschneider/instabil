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
      
      it 'displays a list of polls' do
        get '/polls'
        last_response.body.should include(title)
      end
    end
  end
end