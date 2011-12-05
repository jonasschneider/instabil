require 'bundler'
Bundler.require :default
$:.unshift 'lib'

require './app/app'

require 'sprockets'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'app/assets/javascripts'
  environment.append_path 'vendor/assets'
  environment.append_path 'app/assets/stylesheets'
  run environment
end

map '/' do
  run Instabil::App
end