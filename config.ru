require 'bundler'
Bundler.require :default
$:.unshift 'lib'

require 'instabil'
require "instabil/frontend/app"

Precious::App.configure do |c|
  c.set :gollum_path, File.join(File.dirname(File.expand_path(__FILE__)), 'wikidata')
  c.set :wiki_options, {}
end


require 'omniauth/strategies/fichteid'

use OmniAuth::Builder do
  use Rack::Session::Cookie
  
  provider :fichteid
  
  configure do |c|
    c.on_failure = Proc.new do |env|
      [400, { 'Content-Type'=> 'text/html'}, [env["omniauth.error.type"]]]
    end
  end
end


run Precious::App
