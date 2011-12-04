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
    
    @ernie_pidfile = Tempfile.new 'ernie-pid'
    @dir = Dir.mktmpdir('instabil-test-run-ernie')
    puts "Starting ernie at #{@dir} with pidfile #{@ernie_pidfile.path}"
    @wd = File.join(File.dirname(__FILE__), '..')
    cmd = "cd #{@wd}; DATA_DIR=#{@dir} ernie -d -c lib/instabil/ernie/ernie.conf -P #{@ernie_pidfile.path}"
    puts cmd
    system(cmd)
    
    puts "waiting for ernie to come up"
    sleep(1) while !is_port_open?('127.0.0.1', 8000)
    puts "ernie is up"
  end
  
  config.after :all do
    pid = File.read(@ernie_pidfile.path)
    if !pid.empty?
      puts "Stopping ernie."
      %x(kill #{pid})
    end
  end

  def login(username, name)
    post '/auth/developer/callback', :username => username, :name => name, :group_ids => app.settings.authorized_group_id
  end
  
  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)
end
