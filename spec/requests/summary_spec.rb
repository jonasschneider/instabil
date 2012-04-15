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

    it "shows info about the courses"
  end
end