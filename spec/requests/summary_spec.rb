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
    let(:avatar_path) { File.join(File.dirname(__FILE__), '..', 'avatar.jpg') }

    before :each do
      # Anna has an avatar
      anna.avatar = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
      anna.save!

      # Jonas has enough tags
      5.times do |i| 
        jonas.tags << Tag.new(name: 'Hallo '+i.to_s, author: anna)
      end

      # Jonas is activated
      anna.active = false
      anna.save!

      login(jonas.uid, jonas.name)
      get '/summary'
    end

    it "shows information" do
      last_response.status.should == 200
      last_response.body.should =~ /Übersicht/i
    end

    it "shows a row for every person" do
      last_response.body.should have_selector('tr.person#person_schneijo td.name', content: 'Jonas Schneider')
    end

    it "shows the state of page assigment" do
      last_response.body.should have_selector('tr.person#person_schneijo td.page_assigned.fail')
      last_response.body.should have_selector('tr.person#person_winteran td.page_assigned.ok')
    end

    it "shows the state of photos" do
      last_response.body.should have_selector('tr.person#person_schneijo td.photo.fail')
      last_response.body.should have_selector('tr.person#person_winteran td.photo.ok')
    end

    it "shows the state of tags" do
      last_response.body.should have_selector('tr.person#person_schneijo td.tags.ok')
      last_response.body.should have_selector('tr.person#person_winteran td.tags.fail')
    end

    it "shows the state of activation" do
      last_response.body.should have_selector('tr.person#person_schneijo td.signup.ok')
      last_response.body.should have_selector('tr.person#person_winteran td.signup.fail')
    end

    it "shows info about the courses"
  end

  context "/comments" do
    before :each do
      tag = anna.tags.build name: 'lolz'
      tag.author = jonas
      anna.save!
        
      login(lukas.uid, lukas.name)
      get '/comments'
    end

    it "displays a list of people" do
      last_response.body.should =~ /Anna/
    end

    it "displays the already added tags" do
      last_response.body.should have_selector("tr#person_winteran .tag", content: 'lolz')
    end

    it "displays a form to enter a new tag" do
      last_response.body.should have_selector("tr#person_winteran form[action='/people/winteran/tags'][method=post] input[name='tag[name]']")
    end
  end
end