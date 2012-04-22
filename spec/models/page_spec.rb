require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Page" do
  before do
    Person.moderator_uids = %w(schneijo)
  end

  let(:me) { Person.create! name: 'Jonas' do |p| p.uid = 'schneijo'; end }
  let(:lukas) { Person.create! name: 'Lukas' do |p| p.uid = 'kramerlu'; end }
  let(:anna) { Person.create! name: 'Anna' do |p| p.uid = 'winteran'; end }
  let(:page) { Page.create(kurs: 5, g8: true, author: lukas) }
  
  it "is valid" do
    page.should be_valid
    page.errors.should be_empty
  end
  
  describe "author" do
    it "is required" do
      p = Page.new
      p.should_not be_valid
      p.author = me
      p.should be_valid
    end
  end

  it "is editable by the author and moderators" do
    page.updatable_by?(lukas).should == true
    page.updatable_by?(me).should == true
    page.updatable_by?(anna).should == false
  end

  describe "when signed off" do
    before :each do
      page.signed_off_by = me
    end

    it "is editable only for moderators" do
      page.updatable_by?(lukas).should == false
      page.updatable_by?(me).should == true
      page.updatable_by?(anna).should == false
    end
  end
  
  describe "versioning" do
    it "creates new versions" do
      page.version.should == 1
      page.versions.length.should == 0

      page.kurs = 6
      
      page.save!
      
      page.versions.length.should == 1
      page.version.should == 2
      
      page.versions.first.kurs.should == 5
    end
  end
  
  describe "#compare" do
    it "works for the first version" do
      page.version.should == 1
      page.compare(0, 1).should == {"text"=>"", "title"=>"", "subtitle"=>"", "author_name"=>"", "kurs"=>5, "g8"=>true}
    end
    
    it "works for a second version" do
      page.update_attributes(kurs: 10)
      
      page.version.should == 2
      page.compare(1, 2).should == { "kurs" => 10 }
    end
  end

  describe "#name" do
    it "works for person pages" do
      me.create_page author: me, text: 'ohai'
      me.page.name.should == 'Personenbericht für Jonas'
    end

    let(:course) { Course.create! name: '4BIO02' }
    
    it "works for course pages" do
      course.page = Page.create text: 'ohai', author: me

      course.page.name.should == 'Kursbericht für 4BIO02'
    end
  end

  describe "#wordcount" do
    it "works" do
      page.text = 'Hello world'
      page.wordcount.should == 2
      page.text = 'Hello worldHello worldHello world'
      page.wordcount.should == 4
    end
  end
end