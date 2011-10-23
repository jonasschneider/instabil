ENV["RACK_ENV"] = 'test'
ENV["API_KEY"] = 'random_string'

require 'pp'
require 'rubygems'
require 'bundler'
Bundler.require :default, :test

project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$:.unshift File.join(project_root, 'lib')

require File.join(project_root, 'app', 'app')

Webrat.configure do |config|
  config.mode = :rack
  config.application_framework = :sinatra
  config.application_port = 4567
end

Rspec.configure do |config|
  config.before :each do
    Person.delete_all
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
