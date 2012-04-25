require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "App API endpoint" do
  let(:key) { 'secret' }
  
  describe "without a proper key" do
    it "is inaccessible" do
      get '/api/people.json', :key => key
      last_response.status.should == 403
    end
  end
  
  describe "with a valid key" do
    before :all do
      app.set :api_key, key
    end
    
    it 'returns [] without any people' do
      get '/api/people.json', :key => key
      last_response.status.should == 200
      last_response.body.should == '[]'
    end
    
    it 'returns something when there are people' do
      make_person name: 'Jonas Schneider', uid: 'schneijo'
      
      get '/api/people.json', :key => key
      
      last_response.status.should == 200
      last_response.body.should_not == '[]'
    end
  
    describe "GET /api/courses.json?key=<key>" do
      it 'returns [] without any courses' do
        get '/api/courses.json', :key => key
        last_response.status.should == 200
        last_response.body.should == '[]'
      end
      
      it 'returns something when there are courses' do
        Course.create! subject: 'bio', num: 4, teacher: 'Kunz', weekday: 3, creator: make_person(name: 'Jonas', uid: 'schneijo')
        
        get '/api/courses.json', :key => key
        
        last_response.status.should == 200
        last_response.body.should_not == '[]'
      end
    end
  end
end
