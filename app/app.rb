require 'sinatra'
require 'omniauth/strategies/fichteid'

require 'instabil'

dir = File.dirname(File.expand_path(__FILE__))
require "#{dir}/auth"
require "#{dir}/models/page"
require "#{dir}/models/person"

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
  
  use Rack::Flash

  def section(key, *args, &block)
    @sections ||= Hash.new{ |k,v| k[v] = [] }
    if block_given?
      @sections[key] << block
    else
      @sections[key].inject(''){ |content, block| content << capture_haml(&block) } if @sections.keys.include?(key)
    end
  end

  get '/' do
    authenticate!
    haml :index
  end
  
  get '/api' do
    halt 403, 'Forbidden' unless params[:key] == settings.api_key
    Person.all.map{ |p| p.api_attributes }.to_json
  end
  
  get '/people/:uid/page/edit' do
    authenticate!
    @person = Person.find(params[:uid])
    @page = @person.page || @person.build_page
    haml :edit_page
  end
  
  get '/people/:uid/page' do
    authenticate!
    @person = Person.find(params[:uid])
    @page = @person.page || @person.build_page
    haml :page
  end
  
  post '/people/:uid/page' do
    authenticate!
    @person = Person.find(params[:uid])
    @page = @person.page || @person.build_page
    @page.update_attributes params[:page]
    if @page.save && @person.save
      flash[:notice] = "Seite aktualisiert."
      redirect "/people/#{params[:uid]}/page"
    else
      flash.now[:error] = "Fehler beim Speichern."
      haml :edit_page
    end
  end
end