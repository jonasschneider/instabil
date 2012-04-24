#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import json, os
from string import Template
from optparse import OptionParser
import subprocess

def esc(foo) :
	return foo.lower().replace("ö", "oe").replace("ß", "ss").replace("ü", "ue").replace("ä", "ae").replace(" ", "")

dates= {}
for l in open("dates").readlines() :
	m = l.split("\t")
	lastname = m[3]
	firstname = m[4]
	dates[esc(lastname)[0:6]+esc(firstname)[0:2]]=m[0]

def beautiy_quotation(text) :
	quotation  = ","
	out = ""
	text = text.replace(u"—", "--")

	text = text.replace("&nbsp;", "\\/")
	for c in text :
		if c != '"' :
			out += c
		else :
			if quotation == "," :
				out += quotation*2
				quotation = "'"
			else :
				out += quotation*2
				quotation = ","
	return out

def md2tex(text) :
	proc = subprocess.Popen("./md2tex.sh", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
	return proc.communicate(text.encode("utf-8"))[0].decode("utf-8")

def escape_tex(text) :
	return text.replace(u"♥", "<3").replace(u"☺", " :) ").replace("&#3232;", u"{\\Tunga ಠ}").replace("&", "\\&").replace("#", "\\#").replace("_", "\\_").replace("^", "\^{}").replace(u"%", "\%")

parser = OptionParser()
parser.add_option("-s", "--spoiler", dest="spoiler", help="Spolier text", action="store_true")
(options, args) = parser.parse_args()
spoiler = open("spoilertext").read()
f = open("pupils.json")
blah = f.read()
j = json.loads(blah)
temp = open("temp/pupil.tex").read()
pupillist = []
emails = 0

fixes = {"4f8b0655146fa40001000014" : "{\\Chinese %s}",
"4f96b816079d0500010000fd":"{\\Fixed %s}"}

print 'Namen zu lang:'
for pupil in j :
	page = Template(temp.decode("utf-8"))
	
	content = pupil["page"]
	if pupil["email"] != None and pupil["email"] != "" :
		#print pupil["email"]
		emails += 1
	
	content["uid"] = pupil["uid"]
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
	print pupil["uid"] + ' - ' + pupil["name"]
	content["name"]=content["name"].upper().replace(u'ß', 'SS')
	if content["author"] == "":
		content["author"] = "Dieser Text wurde von ganz vielen geschrieben... "
	content["name"]=content["name"].upper()
	content["name"] = content["name"].replace(u"ё", '"e')
	if content["uid"] == "mahlerda":
		content["name"] = "\LARGE "+content["name"]
	if content["g8"]==1 :
		content["g8"] = "G8"
	elif content["g8"]==0 :
		content["g8"] = "G9"
	elif content["g8"]==2 :
		content["g8"] = "G8/G9 \\em{fixme}"
	content["lks"] = escape_tex(content["lks"] or "")
	content["lebenswichtig"] = escape_tex(content["lebenswichtig"] or "")
	#print type(content["tags"])
	content["geb"] = dates[content["uid"][0:8]]
	if content["tags"] != None and not options.spoiler:
		tags = []
		for t in content["tags"] :
			if t[1] in fixes :
				tags.append(escape_tex(beautiy_quotation(fixes[t[1]]%t[0])))
			else:
				tags.append(escape_tex(beautiy_quotation(t[0])))
		content["tags"] = " +++ ".join(tags)
		 
		 
	
	else : 
		content["tags"] = "Hier kommen Tags hin!"
	#content["tags"] = content["tags"].replace("%", "\\%")
	if content["text"] != None and not options.spoiler:
		proc = subprocess.Popen("./md2tex.sh", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		content["text"] = proc.communicate(content["text"].encode("utf-8"))[0].decode("utf-8")
	else :
		content["text"] = spoiler;

	out = page.substitute(content)
	#out = out
	f =  open("tex/pupils/" + pupil["uid"] + ".tex", "w")
	f.write(out.encode("utf-8"))
print "%i Schüler, %i mit email"%(len(pupillist), emails)
pupillist.sort()
f =  open("tex/pupilspages.tex", "w")
for p in pupillist :
	f.write("\input{pupils/" + p + ".tex}\n");
