require 'bundler'
Bundler.require :default
$:.unshift 'lib'

require 'instabil'
require './app/app'

Precious::App.configure do |c|
  c.set :gollum_path, File.join(File.dirname(File.expand_path(__FILE__)), 'wikidata')
  c.set :wiki_options, {}
end

run Precious::App
