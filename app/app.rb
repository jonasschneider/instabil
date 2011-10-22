require 'sinatra'

dir = File.dirname(File.expand_path(__FILE__))

require "#{dir}/models/page"
require "#{dir}/models/person"

class Instabil::App < Sinatra::Base
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new.db("instabil_development")
  end
  
  get '/' do
    Person.all.inspect
  end
  
  get '/people/:uid/page/edit' do
    @page = Person.find(params[:uid]).page
    haml :edit_page
  end
end