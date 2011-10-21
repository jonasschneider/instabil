require 'rubygems'
require 'ernie'
require 'grit'

module Ext
  def add(a, b)
    a + b
  end
  
  def grit_call(git_dir, method, arguments)
    git = Grit::Git.new git_dir
    git.send method, *arguments
  end
end

Ernie.expose(:ext, Ext)