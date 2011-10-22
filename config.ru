require 'bundler'
Bundler.require :default
$:.unshift 'lib'

require 'instabil'
require './app/app'

run Instabil::App
