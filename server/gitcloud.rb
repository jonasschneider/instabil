require 'rubygems'
require 'ernie'
require 'grit/git'

module Gitcloud
  def grit_call(git_path, method, arguments)
    git = Grit::Git.new git_path
    git.send method, *arguments
  end
  
  def add(a, b)
    a + b
  end
end

Ernie.expose(:gitcloud, Gitcloud)
