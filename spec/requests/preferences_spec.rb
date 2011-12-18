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
    
    let(:avatar_path) { File.join(File.dirname(__FILE__), '..', 'avatar.jpg') }
    
  
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
        
        last_response.should have_selector form + ' input[name="person[avatar]"][type=file]'
        
        last_response.should have_selector 'img[src="'+lukas.avatar_url(:medium)+'"]'
      end
    end
    
    describe "visiting /people/<uid>/avatar/original" do
      it "displays the avatar image by default" do
        get "/people/kramerlu/avatar/original"
        last_response.body.length.should == File.size(File.join(File.dirname(__FILE__), '../../app/public/images/avatar.jpg'))
      end
      
      it "displays the user's avatar" do
        lukas.avatar = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
        lukas.save!
        get "/people/kramerlu/avatar/original"
        last_response.body.length.should == File.size(avatar_path)
      end
    end
    
    describe "visiting /people/<uid>/avatar/medium" do
      it "displays the user's avatar" do
        lukas.avatar = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
        lukas.save!
        get "/people/kramerlu/avatar/medium"
        last_response.body.length.should == lukas.avatar.to_file(:medium).size
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
      
      describe "with an avatar" do
        it "updates the avatar" do
          f = Rack::Test::UploadedFile.new(avatar_path, 'avatar.jpg')
          post "/preferences", person: { avatar: f }
          lukas.reload
          lukas.avatar.original_filename.should == 'avatar.jpg'
          lukas.avatar.to_file.length.should == File.size(avatar_path)
        end
        
        it "requires an image" do
          f = Rack::Test::UploadedFile.new(__FILE__, 'app_spec.rb')
          post "/preferences", person: { avatar: f }
          lukas.reload
          lukas.avatar.original_filename.should_not == 'app_spec.rb'
        end
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