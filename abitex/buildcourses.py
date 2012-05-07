#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import json, os, subprocess, itertools
from string import Template
f = open("courses.json")
blah = f.read()
j = json.loads(blah)
temp = open("temp/course.tex").read()
n = 0
import common

def escape_tex(text) :
	return text.replace(u"♥", "<3").replace(u"☺", " :) ").replace("&#3232;", u"{\\Tunga ಠ}").replace("&", "\\&").replace("#", "\\#").replace("_", "\\_").replace("^", "\^{}").replace(u"%", "\%").replace(u"✚", u"{\\DjVu ✚}").replace(u"‿", u"{\\DjVu ‿}").replace(u"✿", u"{\\DjVu ✿}").replace(u"ё", '"e').replace(u"§nl§", u"\\\\").replace("\\textbackslash\\/LaTeX", "\\LaTeX").replace("\\textbackslash\\/vspace", "\\vspace").replace("\\m/", "\\textbackslash m/")

def removeNonAscii(s): return "".join(i for i in s if ord(i)<128)

for course in j :
	n+=1
	page = Template(temp.decode("utf-8"))
	#if course["author"] == "" :
	#	continue
	#print course["id"]
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
	
	if common.drafting():
		course["text"] = escape_tex(course["text"])
	else:
		proc = subprocess.Popen("./md2tex.sh", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		course["text"] = proc.communicate(course["text"].encode("utf-8"))[0].decode("utf-8")

	course["authorspace"] = ""

	if common.drafting():
		if not os.path.exists('linked/courses/clouds/%s.jpg'%course["id"]):
			print '%s: No course cloud draft'%course["id"]
			course["cloud"] = "\\rule{\\textwidth}{90mm}"
		else:
			course["cloud"] = "\\includegraphics[width=\\textwidth]{../linked/courses/clouds/%s.jpg}"%course["id"]
	else:
		if not os.path.exists('linked/courses/clouds/%s.png'%course["id"]):
			print '%s: No course cloud'%course["id"]
			course["cloud"] = "\\rule{\\textwidth}{90mm}"
		else:
			course["cloud"] = "\\includegraphics[width=\\textwidth]{../linked/courses/clouds/%s.png}"%course["id"]
	
	if int(course["num"]) == 4:
		if os.path.exists('linked/courses/grouppics/%s.jpg'%course["id"]):
			course["pic"] = "{\centering \\includegraphics[width=\\textwidth]{../linked/courses/grouppics/%s.jpg}}"%course["id"] 
		else:
			course["pic"] = "{\centering \\rule{\\textwidth}{90mm}}"
			print '%s: No course pic (%s)'% (course["id"], removeNonAscii(course["fach"]+" "+course["lehrer"]))
		if len(course["author"].strip()) > 3:
			# FIXME: add tag block
			course["cloud"] = ""
			course["authorspace"] = "\\vspace{2cm}"
	else:
		# FIXME: add small pics
		course["pic"] = "\\rule{\\textwidth}{20mm}" 

	course["author"] = escape_tex(course["author"])
	
	out = page.substitute(course)
	f =  open("tex/courses/" + course["id"] + ".tex", "w")
	f.write(out.encode("utf-8"))
print "%i Kurse"%n
f =  open("tex/courses.tex", "w")

getnum = lambda s:s['num']
getsubject = lambda s:s['fach']

sorted_input = reversed(sorted(j, key=getnum))
for num,courses in itertools.groupby(sorted_input, key=getnum):
	sorted_by_subject = sorted(courses, key=getsubject)
	for course in sorted_by_subject:
		f.write("\input{courses/" + course["id"] + ".tex}\n");
