#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import json, os, subprocess, itertools
from string import Template
f = open("courses.json")
blah = f.read()
j = json.loads(blah)
temp = open("temp/course.tex").read()
n = 0

def escape_tex(text) :
	return text.replace(u"♥", "<3").replace(u"☺", " :) ").replace("&#3232;", u"{\\Tunga ಠ}").replace("&", "\\&").replace("#", "\\#").replace("_", "\\_").replace("^", "\^{}").replace(u"%", "\%").replace(u"✚", u"{\\DjVu ✚}").replace(u"‿", u"{\\DjVu ‿}").replace(u"✿", u"{\\DjVu ✿}").replace(u"ё", '"e').replace(u"§nl§", u"\\\\").replace("\\textbackslash\\/LaTeX", "\\LaTeX").replace("\\textbackslash\\/vspace", "\\vspace").replace("\\m/", "\\textbackslash m/")

for course in j :
	n+=1
	page = Template(temp.decode("utf-8"))
	#if course["author"] == "" :
	#	continue
	print course["id"]
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
	course["fach"] = course["fach"].upper()
	course["fach"] = "GK" if course["fach"] == "GEMEINSCHAFTSKUNDE" else course["fach"]
	course["lehrer"] = course["lehrer"].upper()
	course["text"] = escape_tex(course["text"])
	#proc = subprocess.Popen("./md2tex.sh", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
	#course["text"] = proc.communicate(course["text"].encode("utf-8"))[0].decode("utf-8")

	if len(course["author"].strip()) > 2:
		course["author"] = "von "+escape_tex(course["author"])
	
	out = page.substitute(course)
	f =  open("tex/courses/" + course["id"] + ".tex", "w")
	f.write(out.encode("utf-8"))
print "%i Kurse"%n
f =  open("tex/courses.tex", "w")

getnum = lambda s:s['num']
getsubject = lambda s:s['fach']

sorted_input = reversed(sorted(j, key=getnum))
for num,courses in itertools.groupby(sorted_input, key=getnum):
	f.write("\section{%d-stündige Kurse}\n"%num);
	sorted_by_subject = sorted(courses, key=getsubject)
	for course in sorted_by_subject:
		f.write("\input{courses/" + course["id"] + ".tex}\n");
