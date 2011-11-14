#!/usr/bin/env python2

import json, os
from string import Template
f = open("coursetest.json")
blah = f.read()
j = json.loads(blah)
temp = open("temp/course.tex").read()
pupillist = []
for course in j :
	page = Template(temp.decode("utf-8"))
	pupillist.append(course["id"])
	#print "tex/pupils/" + pupil["uid"] + ".tex"
	#print type(content["tags"])
	if course["tags"] != None :
		course["tags"] = "\//\/".join(course["tags"])
	else : 
		course["tags"] = ""
	out = page.substitute(course)
	f =  open("tex/coursereports/" + course["id"] + ".tex", "w")
	f.write(out.encode("utf-8"))

f =  open("tex/courses.tex", "w")
for p in pupillist :
	f.write("\input{coursereports/" + p + ".tex}\n");
