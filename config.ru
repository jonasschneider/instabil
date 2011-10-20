require 'bundler'
Bundler.require :default
$:.unshift 'lib'

require 'instabil'
require "instabil/frontend/app"

Precious::App.configure do |c|
  c.set :gollum_path, File.join(File.dirname(File.expand_path(__FILE__)), 'wikidata')
  c.set :wiki_options, {}
end


require 'omniauth/strategies/fichte'

use OmniAuth::Builder do
  use Rack::Session::Cookie
  
  provider :fichte
  
  configure do |c|
    c.on_failure = Proc.new do |env|
      new_path = "#{OmniAuth.config.path_prefix}/fichte?error=#{env["omniauth.error.type"]}"
      [302, {'Location' => "#{new_path}", 'Content-Type'=> 'text/html'}, []]
    end
  end
end


run Precious::App
