#!/usr/bin/env python2

import json, os

f = open("test.json")
blah = f.read()
#print blah
j = json.loads(blah)
temp = open("temp/pupil.tex").read()
pupillist = []
for pupil in j :
	page = temp.decode("utf-8")
	content = pupil["page"]
	print pupil["uid"]
	pupillist.append(pupil["uid"])
	#print "tex/pupils/" + pupil["uid"] + ".tex"
	page = page.replace("__name", pupil["name"])
	page = page.replace("__kurs", str(content["kurs"]))
	if eval(str(content["g8"])) :
		g8 = "G8"
	else :
		g8 = "G9"
	page = page.replace("__g8", g8)
	page = page.replace("__bio", content["bio"])
	page = page.replace("__text_by", content["text_by"])
	page = page.replace("__text", content["text"])
	page = page.replace("__bio", content["bio"])
	page = page.replace("__tags", "+++".join(content["tags"]))
	f =  open("tex/pupils/" + pupil["uid"] + ".tex", "w")
	f.write(page.encode("utf-8"))

f =  open("tex/pupilspages.tex", "w")
for p in pupillist :
	f.write("\input{pupils/" + p + ".tex}\n");
