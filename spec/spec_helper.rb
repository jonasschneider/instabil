require File.expand_path(File.join(File.dirname(__FILE__), 'boot'))
ENV["RACK_ENV"] = 'test'
ENV["API_KEY"] = 'random_string'

project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require File.join(project_root, 'app', 'app')

Webrat.configure do |config|
  config.mode = :rack
  config.application_framework = :sinatra
  config.application_port = 4567
end

Rspec.configure do |config|
  config.before :each do
    Mongoid.master.collections.select do |collection| 
      collection.name !~ /system/ 
    end.each(&:drop) 
  end
  
  def app
    Instabil::App
  end
  
  def login(username, name)
    post '/auth/developer/callback', :username => username, :name => name, :group_ids => app.settings.authorized_group_id
  end

  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)
end
