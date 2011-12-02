require 'instabil'

require 'redcarpet'

dir = File.dirname(File.expand_path(__FILE__))
require "#{dir}/boot" 
require "#{dir}/auth"
require "#{dir}/versions"
require "#{dir}/polls"
require "#{dir}/pages"


require "#{dir}/models/page"
require "#{dir}/models/course"
require "#{dir}/models/person"
require "#{dir}/models/message"
require "#{dir}/models/answer"
require "#{dir}/models/vote"
require "#{dir}/models/poll"

Pusher.url = ENV['PUSHER_URL'] || "http://9c903bcb2ab8ded787c1:9feb791ebc2ce7bf9143@api.pusherapp.com/apps/11445"

class Instabil::App < Sinatra::Base
  Mongoid.configure do |config|
    config.master = begin
      if ENV['MONGOHQ_URL']
        uri = URI.parse(ENV['MONGOHQ_URL'])
        Mongo::Connection.from_uri(ENV['MONGOHQ_URL']).db(uri.path.gsub(/^\//, ''))
      else
        Mongo::Connection.new.db("instabil_#{environment}")
      end
    end
  end
  
  use Rack::Session::Cookie
  
  set :authorized_group_id, 10095
  
  if ENV['API_KEY']
    set :api_key, ENV['API_KEY']
  else
    puts "WARNING: No API key set."
    set :api_key, "1234"
  end
  
  register Instabil::Auth
  register Instabil::Versions
  register Instabil::Polls
  register Instabil::Pages
  
  use Rack::Flash

  def section(key, *args, &block)
    @sections ||= Hash.new{ |k,v| k[v] = [] }
    if block_given?
      @sections[key] << block
    else
      @sections[key].inject(''){ |content, block| content << capture_haml(&block) } if @sections.keys.include?(key)
    end
  end
  
  def markdown(text)
    @markdown ||= Redcarpet::Markdown.new Redcarpet::Render::HTML
    @markdown.render text
  end

  get '/' do
    authenticate!
    haml :index
  end
  
  get '/api' do
    halt 403, 'Forbidden' unless params[:key] == settings.api_key
    Person.all.map{ |p| p.api_attributes }.to_json
  end
  
  get '/preferences' do
    authenticate!
    @person = current_user
    haml :preferences
  end
  
  post '/preferences' do
    authenticate!
    @person = current_user
    
    if @person.update_attributes params[:person]
      flash[:notice] = "Einstellungen gespeichert."
      redirect '/'
    else
      flash[:error] = "Fehler beim Speichern. Ist die E-Mail-Addresse korrekt?"
      haml :preferences
    end
  end
  
  post '/messages' do
    authenticate!
    msg = Message.new author: current_user, body: params[:message][:body]
    if msg.save
      Pusher['chat'].trigger :message, msg.client_attributes
    end
    redirect '/#chat'
  end
  
  get '/people/:uid' do
    authenticate!
    @person = Person.find(params[:uid])
    
    haml :person
  end
  
  get '/courses' do
    haml :courses
  end
  
  get '/courses/:id' do
    @course = Course.find params[:id]
    haml :course
  end
end