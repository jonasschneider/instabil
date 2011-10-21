class Raiser
  def initialize name
    @name = name
  end
  
  def method_missing method, *args
    raise "[#{@name}] Unauthorized call to #{method} with #{args.inspect}"
  end
end