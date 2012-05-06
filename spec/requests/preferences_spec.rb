require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Preferences" do
  describe "viewed as lukas" do
    let(:jonas) do
      Person.create! name: "Jonas Schneider" do |p|
        p.uid = "schneijo"
      end
    end
    
    let(:lukas) do
      Person.create! name: "Lukas" do |p|
        p.uid = "kramerlu"
      end
    end
    
    before :each do
      login(lukas.uid, lukas.name)
    end
    
    describe "visiting /preferences" do
      it "shows a form for the user to edit name and email" do
        lukas.update_attributes(name: 'Asdfname', email: 'test@example.com')
        lukas.save!
        get "/preferences"
        form = "form[action='/preferences'][method=post]"
        last_response.should have_selector form
        last_response.should have_selector form + ' input[name="person[name]"][type=text][value=Asdfname]'
        last_response.should have_selector form + ' input[name="person[email]"][type=text][value="test@example.com"]'
        last_response.should have_selector form + ' input[type=submit]'
        
        last_response.should have_selector form + ' input[name="person[kurs]"][type=text]'
        last_response.should have_selector form + ' input[name="person[g8]"][type=checkbox]'
        
        last_response.should have_selector form + ' input[name="person[zukunft]"][type=text]'
        last_response.should have_selector form + ' input[name="person[nachabi]"][type=text]'
        last_response.should have_selector form + ' input[name="person[lebenswichtig]"][type=text]'
      end
    end
    
    describe "POSTing to /preferences" do
      let(:new_name) { 'Laggas' }
      let(:new_email) { 'test@0x83.eu' }
      let(:old_uid) { lukas.uid }
      
      it "updates the users attributes" do
        old_uid
        post "/preferences", person: { name: new_name, email: new_email, bio: 'testing' }
        lukas.reload.name.should == new_name
        lukas.email.should == new_email
        lukas.uid.should == old_uid
        lukas.bio.should == 'testing'
      end
      
      describe "with a bogus email" do
        let(:new_email) { 'test0x83.eu' }
        
        it "updates the users attributes" do
          old_uid
          post "/preferences", person: { name: new_name, email: new_email, bio: 'testing' }
          lukas.email.should_not == new_email
          last_response.body.should include('Fehler')
        end
      end
    end
  end
end