require "./stub"
require 'gollum'

svc = BERTRPC::Service.new('localhost', 8000)
puts "Test should be 3: "+svc.call.ext.add(1, 2).to_s

#repo = Grit::Repo.new("/home/jonas/code/fis")
#repo.git = Gitcloud::Stub.new("/home/jonas/code/fis/.git")


@wiki = Gollum::Wiki.new('/home/jonas/code/instabil/wikidata', {})

stub = Gitcloud::Stub.new('/home/jonas/code/instabil/wikidata/.git')
@wiki.repo.git = stub
#@wiki.repo.git = Gitcloud::Arbiter.new @wiki.repo.git, stub

puts @wiki.page('Home').inspect