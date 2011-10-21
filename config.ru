require 'bundler'
Bundler.require :default
$:.unshift 'lib'

require 'instabil'
require './app/app'

run Precious::App
