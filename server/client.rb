require "./stub"
require 'gollum'

#repo = Grit::Repo.new("/home/jonas/code/fis")
#repo.git = Gitcloud::Stub.new("/home/jonas/code/fis/.git")


@wiki = Gollum::Wiki.new('/home/jonas/code/instabil/wikidata', {})

stub = Gitcloud::Stub.new('/home/jonas/code/instabil/wikidata/.git')
@wiki.repo.git = stub
#@wiki.repo.git = Gitcloud::Arbiter.new @wiki.repo.git, stub

puts @wiki.page('Home').inspect