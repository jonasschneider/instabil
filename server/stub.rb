require 'bertrpc'
require 'grit'
require 'gollum'

module Gitcloud
  class StubbedRepo < Grit::Repo
    def initialize path, git
      self.path = path
      self.git = git
    end
  end
  
  class GollumGitAccess < Gollum::GitAccess
    def initialize git_dir, hostname, port
      git = GritGitStub.new git_dir, hostname, port
      @page_file_dir = nil
      @path = Dir.mktmpdir
      @repo = StubbedRepo.new @path, git
      clear
    end
  end
  
  class GritGitStub
    def initialize git_dir, hostname, port
      @svc = BERTRPC::Service.new(hostname, port)
      @git_dir = git_dir
    end
    
    def method_missing method, *args
      print "calling #{method} with #{args.inspect}"
      res = @svc.call.gitcloud.grit_call @git_dir, method, args
      puts " -> #{res.inspect}"
      res
    end
  end
end