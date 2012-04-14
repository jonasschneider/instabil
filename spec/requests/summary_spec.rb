require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Instabil::Summary" do
  before do
    Person.moderator_uids = %w(schneijo)
  end

  let(:jonas) do
    Person.create! name: "Jonas Schneider" do |p|
      p.uid = "schneijo"
    end
  end
  
  let(:lukas) { make_person name: "Lukas", uid: "kramerlu" }
  
  let!(:anna) do
    Person.create!(name: "Anna") do |anna|
      anna.uid = "winteran"
    end.tap do |anna|
      anna.create_page text: 'Text', author: jonas
    end
  end

  describe "as normal user" do
    before :each do
      login(lukas.uid, lukas.name)
      get '/summary'
    end

    it "403's" do
      last_response.status.should == 403
      last_response.body.should =~ /nicht autorisiert/
    end
  end

  describe "as moderator" do
    before :each do
      login(jonas.uid, jonas.name)
      get '/summary'
    end

    it "shows information" do
      last_response.status.should == 200
      last_response.body.should =~ /Übersicht/i
      last_response.body.should =~ /#{Person.count}/
      last_response.body.should =~ /#{Course.count}/
    end

    it "shows a row for every person" do
      last_response.body.should have_selector('tr.person#person_schneijo td.name', content: 'Jonas Schneider')
    end

    it "shows the state of page assigment" do
      last_response.body.should have_selector('tr.person#person_schneijo td.page_assigned.fail')
      last_response.body.should have_selector('tr.person#person_winteran td.page_assigned.ok')
    end
  end
end