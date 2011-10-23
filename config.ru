require 'bundler'
Bundler.require :default
$:.unshift 'lib'

require './app/app'

run Instabil::App
