require File.expand_path(File.join(File.dirname(__FILE__), 'boot'))
ENV["API_KEY"] = 'random_string'
require "tmpdir"
require 'socket'

def is_port_open?(ip, port)
  begin
    TCPSocket.new(ip, port)
  rescue Errno::ECONNREFUSED
    return false
  end
  return true
end

project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

Paperclip.options[:log] = false
$stdout.sync = true

require File.join(project_root, 'app', 'app')
Webrat.configure do |config|
  config.mode = :rack
  config.application_framework = :sinatra
  config.application_port = 4567
end

RSpec.configure do |config|
  config.before :each do
    Mongoid.master.collections.select do |collection| 
      collection.name !~ /system/ 
    end.each(&:drop) 
    Pusher::Channel.stub(:trigger).and_return(true)
  end
  
  def app
    Instabil::App
  end
  
  config.before :all do
    app.configure do
      disable :show_exceptions
      enable :raise_errors
    end
  end

  def login(username, name)
    post '/auth/developer/callback', :username => username, :name => name, :group_ids => app.settings.authorized_group_id
  end
  
  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)
end
