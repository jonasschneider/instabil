#!/usr/bin/env python2

import json, os, subprocess
from string import Template
f = open("courses.json")
blah = f.read()
j = json.loads(blah)
temp = open("temp/course.tex").read()
courselist = []
n = 0
for course in j :
	n+=1
	page = Template(temp.decode("utf-8"))
	if course["author"] == "" :
		continue
	courselist.append(course["name"])
	print course["name"]
	#print "tex/pupils/" + pupil["uid"] + ".tex"
	#print type(content["tags"])
	"""if course["tags"] != None :
		course["tags"] = "\//\/".join(course["tags"])
	else : 
		course["tags"] = """
	if int(course["num"]) == 4 :
		course["type"] = "vier"
	else :
		course["type"] = "zwei"
	proc = subprocess.Popen("./md2tex.sh", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
	course["text"] = proc.communicate(course["text"].encode("utf-8"))[0].decode("utf-8")
	out = page.substitute(course)
	f =  open("tex/coursereports/" + course["name"] + ".tex", "w")
	f.write(out.encode("utf-8"))
print "%i Kurse, %i berichte"%(n, len(courselist))
f =  open("tex/courses.tex", "w")
for p in courselist :
	f.write("\input{coursereports/" + p + ".tex}\n");
