require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Instabil::Courses" do
  let(:jonas) do
    Person.create! name: "Jonas Schneider" do |p|
      p.uid = "schneijo"
    end
  end
  
  let(:lukas) { make_person name: "Lukas", uid: "kramerlu" }
  
  before :each do
    login(lukas.uid, lukas.name)
  end

  let(:course) { Course.create! subject: 'e', num: 4, weekday: 0, teacher: 'Schürer', creator: jonas }
  let(:page) { Page.create! text: 'bla', author: lukas }

  describe "/courses" do
    it "can create a main course via form" do
      visit '/courses'
      fill_in 'course[teacher]', with: 'Schürer'
      select 'Montag'
      select 'Erdkunde'
      click_button 'Als vierstündigen Kurs eintragen'
      c=Course.first
      c.subject.should == 'geo'
      c.num.should == 4
      c.weekday.should == 0
      c.teacher.should == 'Schürer'
      c.creator.should == lukas
    end

    it "shows a link to create the course page if there is none" do
      course
      visit '/courses'
      last_response.body.should include("Kursbericht schreiben")
    end

    it "shows a link to remove a tag by the user" do
      course.tags.create name: 'lol', author: lukas
      visit '/courses'
      last_response.body.should have_selector("form[action='/courses/#{course.id}/untag/#{course.tags.first.id}'][method=post]")
      click_button 'Löschen'
      course.reload.tags.should == []
    end

    it "shows no link to remove a tag by another user" do
      course.tags.create name: 'lol', author: jonas
      visit '/courses'
      last_response.body.should_not have_selector("form[action='/courses/#{course.id}/untag/#{course.tags.first.id}'][method=post]")
    end

    it "shows a link to the course page if there is one" do
      course.page = page
      course.save!
      visit '/courses'

      last_response.body.should have_selector "a[href='/courses/#{course.id}']"
      last_response.body.should_not have_selector "a[href='/pages/new?for_course=#{course.id}']"
    end
  end

  describe "visiting /courses/<id>" do
    before :each do
      get "/courses/#{course.id}"
    end
    
    it "404's when the course has no page" do
      last_response.status.should == 404
    end
    
    describe "when the course has a page" do
      let(:page) { Page.create! text: 'bla', author: lukas }
      
      before :each do
        course.page = page
        course.save!
        get "/courses/#{course.id}"
      end
      
      it "shows the page content" do
        last_response.body.should include(page.text)
      end
      
      it "shows a link to edit the page" do
        last_response.body.should have_selector "a[href='/pages/#{page.id}/edit']"
      end
      
      describe "by someone else" do
        it "shows no link to edit the page" do
          course.page = Page.create! text: 'bla', author: jonas
          course.save!
          get "/courses/#{course.id}"
          last_response.body.should_not have_selector "a[href='/pages/#{page.id}/edit']"
        end
      end
    end
  end
end