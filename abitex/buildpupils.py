#!/usr/bin/env python2

import json, os
from string import Template
f = open("test.json")
blah = f.read()
j = json.loads(blah)
temp = open("temp/pupil.tex").read()
pupillist = []
for pupil in j :
	page = Template(temp.decode("utf-8"))
	content = pupil["page"]
	print pupil["uid"]
	pupillist.append(pupil["uid"])
	#print "tex/pupils/" + pupil["uid"] + ".tex"
	content["name"] = pupil["name"]
	if content["g8"]==1 :
		content["g8"] = "G8"
	else :
		content["g8"] = "G9"
	#print type(content["tags"])
	if content["tags"] != None :
		content["tags"] = "\//\/".join(content["tags"])
	else : 
		content["tags"] = ""
	out = page.substitute(content)
	f =  open("tex/pupils/" + pupil["uid"] + ".tex", "w")
	f.write(out.encode("utf-8"))

f =  open("tex/pupilspages.tex", "w")
for p in pupillist :
	f.write("\input{pupils/" + p + ".tex}\n");
