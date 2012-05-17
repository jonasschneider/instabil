#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import json, os, subprocess, itertools
from string import Template
f = open("courses.json")
blah = f.read()
j = json.loads(blah)
temp = open("temp/course.tex").read()
bericht_temp = open("temp/kursbericht.tex").read()
n = 0
import common

course_members = json.loads(open("course_members.json").read())
pupils = json.loads(open("pupils.json").read())

def removeNonAscii(s): return "".join(i for i in s if ord(i)<128)

class TeXTemplate(Template) :
	delimiter = "#"

for course in j :
	n+=1
	page = TeXTemplate(temp.decode("utf-8"))
	bericht_page = TeXTemplate(bericht_temp.decode("utf-8"))
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

	if course["id"] in course_members:
		course["members"] = ', '.join([filter(lambda p: p["uid"] == member, pupils)[0]["name"] for member in sorted(course_members[course["id"]])])
	else:
		course["members"] = "FIXME: Wer ist hier drin? "+course["id"]
		print '%s: No course list (%s)'% (course["id"], removeNonAscii(course["fach"]+" "+course["lehrer"]))
	
	course["text"] = common.escape_tex(course["text"])

	if common.drafting():
		if not os.path.exists('tex/courseclouds/%s.jpg'%course["id"]):
			print '%s: No course cloud draft'%course["id"]
			course["cloud"] = "\\rule{\\textwidth}{90mm}"
		else:
			course["cloud"] = "{\\centering \\includegraphics[width=\\textwidth]{courseclouds/%s.jpg}}\\vspace{2mm}"%course["id"]
	else:
		if not os.path.exists('tex/courseclouds/%s.png'%course["id"]):
			print '%s: No course cloud'%course["id"]
			course["cloud"] = "\\rule{\\textwidth}{90mm}"
		else:
			course["cloud"] = "{\\centering \\includegraphics[width=\\textwidth]{courseclouds/%s.png}}\\vspace{4mm}"%course["id"]

	if int(course["num"]) == 4:
		if os.path.exists('tex/grouppics/%s.jpg'%course["id"]):
			course["pic"] = "\\includegraphics[width=\\textwidth]{grouppics/%s.jpg}"%course["id"] 
		else:
			course["pic"] = "\\rule{\\textwidth}{120mm}"
			print '%s: No course pic (%s)'% (course["id"], removeNonAscii(course["fach"]+" "+course["lehrer"]))
	else:
		avas = ["\includegraphics[height=18mm]{processed_peopleavatars/%s.jpg}\\textcolor{white}{\-}"%member for member in sorted(course_members[course["id"]])]
		course["pic"] = ''.join(avas)

	if len(course["text"]) > 400:
		# no cloud for courses with long report
		course["cloud"] = "\kurstags{%s}"%common.format_tags(course["tags"])		

	out = page.substitute(course)
	if len(course["text"]) > 3 or len(course["author"]) > 3:
		course["author"] = common.escape_tex(course["author"])

		if len(course["title"]) > 2 or len(course["subtitle"]) > 2:
			course["embeddedtitle"] = "\\kurstitle{%s}{%s}\n"%(course["title"], course["subtitle"])
		else:
			course["embeddedtitle"] = ""

		out += bericht_page.substitute(course)

	f =  open("tex/courses/" + course["id"] + ".tex", "w")
	f.write(out.encode("utf-8"))
print "%i Kurse"%n
f =  open("tex/courses.tex", "w")

getnum = lambda s:s['num']
getsortkey = lambda s:[('0' if s['fach'] == 'MATHE' else ('1' if s['fach'] == 'DEUTSCH' else s['fach'])) , s['lehrer']]

sorted_input = reversed(sorted(j, key=getnum))
for num,courses in itertools.groupby(sorted_input, key=getnum):
	sorted_by_subject = sorted(courses, key=getsortkey)
	for course in sorted_by_subject:
		f.write("\input{courses/" + course["id"] + ".tex}\n");
