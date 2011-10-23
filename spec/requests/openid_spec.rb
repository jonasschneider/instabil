require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "authing" do
  let(:user)      { 'atmos' }
  let(:password)  { 'hancock' }
  let(:name)      { 'Atmos' }

  it 'works' do
    post '/auth/developer/callback', :username => user, :password => password, :name => name
    last_response.headers['Location'].should == 'http://example.org/'
    follow_redirect!
    last_response.body.should have_selector('.user_name', :content => name)
  end
end
