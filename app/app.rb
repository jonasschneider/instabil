require 'instabil'

require 'redcarpet'

dir = File.dirname(File.expand_path(__FILE__))
require "#{dir}/boot" 
require "#{dir}/auth"
require "#{dir}/polls"
require "#{dir}/pages"
require "#{dir}/people"


require "#{dir}/models/page"
require "#{dir}/models/tag"
require "#{dir}/models/course"
require "#{dir}/models/person"
require "#{dir}/models/message"
require "#{dir}/models/answer"
require "#{dir}/models/vote"
require "#{dir}/models/poll"

Pusher.url = ENV['PUSHER_URL'] || "http://9c903bcb2ab8ded787c1:9feb791ebc2ce7bf9143@api.pusherapp.com/apps/11445"

class CoolUpload
  def initialize(data)
    @tempfile = data[:tempfile]
    @name = data[:filename]
  end
  
  def original_filename 
    @name
  end
  
  def method_missing(method_name, *args, &block) #:nodoc:
    @tempfile.__send__(method_name, *args, &block)
  end

  def respond_to?(method_name, include_private = false) #:nodoc:
    @tempfile.respond_to?(method_name, include_private) || super
  end
end

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
  
  if ENV["AIRBRAKE_API_KEY"].present?
    Airbrake.configure do |config|
      config.api_key = ENV["AIRBRAKE_API_KEY"]
    end
    
    use Airbrake::Rack
    enable :raise_errors
  end
  
  use Rack::Session::Cookie
  
  
  if ENV['API_KEY']
    set :api_key, ENV['API_KEY']
  else
    puts "WARNING: No API key set."
    set :api_key, "1234"
  end
  
  register Instabil::Auth
  
  register Instabil::Polls
  register Instabil::People
  register Instabil::Pages
  
  error Mongoid::Errors::DocumentNotFound do
    halt 404, 'Dokument nicht gefunden.'
  end
  
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
  
  
  ## API
  get '/api/people.json' do
    halt 403, 'Forbidden' unless params[:key] == settings.api_key
    Person.all.map{ |p| p.api_attributes }.to_json
  end
  
  get '/api/courses.json' do
    halt 403, 'Forbidden' unless params[:key] == settings.api_key
    Course.all.map{ |p| p.api_attributes }.to_json
  end
  
  
  ## PDF
  get '/current_pdf' do
    authenticate!
    
    stamp = Time.now.to_i.to_s
    sig = OpenSSL::HMAC.hexdigest('sha1', ENV["PDF_VIEWER_SECRET"], stamp)
    redirect "http://abitex.0x83.eu/?timestamp=#{stamp}&timestamp_sig=#{sig}"
  end
  
  
  ## PREFERENCES
  get '/preferences' do
    authenticate!
    @person = current_user
    haml :preferences
  end
  
  post '/preferences' do
    authenticate!
    @person = current_user
    params[:person][:avatar] = CoolUpload.new(params[:person][:avatar]) unless params[:person][:avatar].nil?
    
    if @person.update_attributes params[:person]
      flash[:notice] = "Einstellungen gespeichert."
      redirect '/'
    else
      flash[:error] = "Fehler beim Speichern. #{Rack::Utils.escape_html(@person.errors.to_a.inspect)}"
      haml :preferences
    end
  end
  
  
  ## CHAT
  post '/messages' do
    authenticate!
    msg = Message.new author: current_user, body: params[:message][:body]
    if msg.save
      Pusher['chat'].trigger :message, msg.client_attributes
    end
    redirect '/#chat'
  end
  
  
  ## COURSES
  get '/courses' do
    haml :courses
  end
  
  get '/courses/:id' do
    @course = Course.find params[:id]
    haml :course
  end
end