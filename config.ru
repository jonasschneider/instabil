require "gollum"
$:.unshift 'lib'
require "instabil/frontend/app"
require "redcarpet"

Precious::App.configure do |c|
  c.set :gollum_path, File.join(File.dirname(File.expand_path(__FILE__)), 'wikidata')
  c.set :wiki_options, {}
end

run Precious::App
