#!/usr/bin/env ruby

$stdout.sync = true
i = 0
until $stdin.eof?
  l = $stdin.readline
  if ENV["DEBUG"]
    puts l
  else
    i += 1
    if i % 10 == 0
      $stdout.write('.')
    end
  end
end
puts