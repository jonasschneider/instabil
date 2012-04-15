require 'bundler'
Bundler.require :default
$:.unshift '../lib'

require '../app/app'

puts "#{Person.count} people in DB."

users_in_file = File.open("allusers", "r").read.split("\n\n").map do |chunk|
	chunk.split("\n").inject({}) do |accum, line|
		next accum if line.strip.empty?
		kv = line.split(": ")
		accum[kv[0]] = kv[1]
		accum
	end
end

puts "#{users_in_file.length} people in file."

users_in_file.each do |u|
	uid = u["uid"]
	name = u["cn"]

	db = Person.where(uid: uid)
	if db.length == 0
		puts "new user: #{uid}"
		u = Person.new name: name, active: false
		u.uid = uid
		u.save!
	end
end