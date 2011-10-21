require 'bertrpc'
require 'grit'


module Gitcloud
  class Arbiter
    def initialize real, fake
      @real = real
      @fake = fake
    end
    
    def method_missing method, *args
      print "calling: #{method} with #{args.inspect}"
      fake_res = nil
      begin
        res = @real.send method, *args
        #puts res.inspect
        fake_res = @fake.send method, *args
      rescue Exception => e
        puts ' -> error: '+e.inspect
        raise e
      else
        if res == fake_res
          puts " -> #{res.inspect}"
          res
        else
          puts " -> mismatch! expected #{res.inspect}, got #{fake_res.inspect}"
          res
        end
      end
    end
  end

  class Stub
    def initialize git_dir
      @svc = BERTRPC::Service.new('localhost', 8000)
      @git_dir = git_dir
    end
    
    def method_missing method, *args
      @svc.call.ext.grit_call @git_dir, method, args
    end
  end
end