#!/usr/bin/env python2
import json, time
last = open(".lastavafetch")
lastfetch = int(last.read().strip())
last.close()

#print lastfetch
f = open("pupils.json")
blah = f.read()
j = json.loads(blah)
#currenttime = int(time.time())
currenttime = 0
for pupil in j :
	if pupil["page"]["foto_mtime"] == None :
		print "cp tex/avatars/none.jpg tex/avatars/%s.jpg"%pupil["uid"]
	else :
		if pupil["page"]["foto_mtime"]>lastfetch :
			print "rm  tex/avatars/%s.jpg"%pupil["uid"]
			print "wget http://instabil.heroku.com%s -O tex/avatars/%s.jpg"%(pupil["page"]["foto"], pupil["uid"])

last = open(".lastavafetch", "w")
last.write(str(int(time.time())))
last.close()
