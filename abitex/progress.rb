#!/usr/bin/env ruby

trap(:INT) { exit }

$stdout.sync = true
i = 0
warnings = ""
until $stdin.eof?
  l = $stdin.readline
  if ENV["DEBUG"]
    puts l
  else
    i += 1
    if i % 10 == 0
      $stdout.write('.')
    end
    warnings << l unless l["Package abitex Warning"].nil?
  end
end
puts
puts warnings unless warnings.empty?