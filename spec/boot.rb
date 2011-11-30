require 'pp'
require 'rubygems'
require 'bundler'
Bundler.require :default, :test

project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$:.unshift File.join(project_root, 'lib')

require File.join(project_root, 'app', 'boot')