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
  register Instabil::Auth
  
  use Rack::Flash
  
  get '/' do
    authenticate!
    haml 'home page'
  end
  
  get '/people/:uid/page/edit' do
    authenticate!
    @person = Person.find(params[:uid])
    @page = @person.page || @person.build_page
    haml :edit_page
  end
  
  post '/people/:uid/page' do
    authenticate!
    @person = Person.find(params[:uid])
    @page = @person.page || @person.build_page
    @page.update_attributes params[:page]
    flash[:notice] = "Seite aktualisiert."
    haml :page
  end
end