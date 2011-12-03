#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import json, os
from string import Template
import subprocess
f = open("pupils.json")
blah = f.read()
j = json.loads(blah)
temp = open("temp/pupil.tex").read()
pupillist = []
for pupil in j :
	page = Template(temp.decode("utf-8"))
	content = pupil["page"]
	print pupil["uid"]
	pupillist.append(pupil["uid"])
	#print "tex/pupils/" + pupil["uid"] + ".tex"last = True
	last = True
	content["name"] = ""
	for c in pupil["name"] :
		if c.isupper() and not last :
			content["name"] += " " + c
		else :
			content["name"] += c
		last = not c.islower()

	
	content["name"] = content["name"].replace(u"ё", '"e')
	if content["g8"]==1 :
		content["g8"] = "G8"
	else :
		content["g8"] = "G9"
	#print type(content["tags"])
	if content["tags"] != None :
		content["tags"] = "\//\/".join(content["tags"])
	else : 
		content["tags"] = ""
	
	if content["text"] != None :
		proc = subprocess.Popen("./md2tex.sh", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		content["text"] = proc.communicate(content["text"].encode("utf-8"))[0].decode("utf-8")
	#proc.kill()
	out = page.substitute(content)
	f =  open("tex/pupils/" + pupil["uid"] + ".tex", "w")
	f.write(out.encode("utf-8"))
print len(pupillist)
pupillist.sort()
f =  open("tex/pupilspages.tex", "w")
for p in pupillist :
	f.write("\input{pupils/" + p + ".tex}\n");
