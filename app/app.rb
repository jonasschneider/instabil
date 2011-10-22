require 'sinatra'
require 'omniauth/strategies/fichteid'

dir = File.dirname(File.expand_path(__FILE__))

require "#{dir}/auth"
require "#{dir}/models/page"
require "#{dir}/models/person"

class Instabil::App < Sinatra::Base
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new.db("instabil_development")
  end
  
  register Instabil::Auth
  
  get '/' do
    authenticate!
    haml 'home page'
  end
  
  get '/people/:uid/page/edit' do
    authenticate!
    @page = Person.find(params[:uid]).page
    haml :edit_page, :layout => 'layout'
  end
end