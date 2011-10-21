require 'rubygems'
require 'ernie'
require 'grit'

module Gitcloud
  def grit_call(git_dir, method, arguments)
    if git_dir == 'wikidata'
      git = Grit::Git.new ENV['WIKIDATA_REPO']
      git.send method, *arguments
    else
      raise "what repo is #{git_dir}? (not literally used as a folder)"
    end
  end
  
  def add(a, b)
    a + b
  end
end

Ernie.expose(:gitcloud, Gitcloud)
