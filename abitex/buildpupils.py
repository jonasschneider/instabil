#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import json, os, os.path
from string import Template
from optparse import OptionParser
import subprocess
import common

def esc(foo) :
	return foo.lower().replace("ö", "oe").replace("ß", "ss").replace("ü", "ue").replace("ä", "ae").replace(" ", "")

dates= {}
for l in open("dates").readlines() :
	m = l.split("\t")
	lastname = m[3]
	firstname = m[4]
	dates[esc(lastname)[0:6]+esc(firstname)[0:2]]=m[0]

def md2tex(text) :
	proc = subprocess.Popen("./md2tex.sh", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
	return proc.communicate(text.encode("utf-8"))[0].decode("utf-8")

parser = OptionParser()
parser.add_option("-s", "--spoiler", dest="spoiler", help="Spolier text", action="store_true")
(options, args) = parser.parse_args()
spoiler = open("spoilertext").read()
f = open("pupils.json")
blah = f.read()
j = json.loads(blah)
if options.spoiler :
	temp = open("temp/spoiler.tex").read()
else: 
	temp = open("temp/pupil.tex").read()
pupillist = []
emails = 0

smallnames = ("mahlerda", "burgerma", "hoffmelo")
verysmallnames = ("leikerch", "meissnna")

sizes = ("\\scriptsize", "\\kathisize", "\\footnotesize", "\\small")

smallmeta = ("elgogoli", "ingentjo", "mahlerda", "weberha", "werrnal", "wolffrda", "reinhaca", "schoepre", "werrnal", "meissnna", "mercanze", "winteran", "broderti", "blumesi", "brassro")
verysmallmeta = ("weilerki", "kramerlu")

print 'Namen zu lang:'

class TeXTemplate(Template) :
	delimiter = "#"

for pupil in j :
	page = TeXTemplate(temp.decode("utf-8"))


	content = pupil["page"]
	content["special"] = ""
	
	if pupil["email"] != None and pupil["email"] != "" :
		#print pupil["email"]
		emails += 1
	
	content["uid"] = pupil["uid"]
	pupillist.append(pupil["uid"])
	if content["uid"] == os.getenv('ABITEX_SPOILER') and common.drafting():
		content["text"] = 'spoilered :)'
	#print "tex/pupils/" + pupil["uid"] + ".tex"last = True
	
	content["uidhint"] = " "+content["uid"] if common.drafting() else ""
	
	last = True
	content["name"] = ""
	for c in pupil["name"] :
		if c.isupper() and not last :
			content["name"] += " " + c
		else :
			content["name"] += c
		last = not c.islower()
	print pupil["uid"]
	content["name"]=content["name"].upper().replace(u'ß', 'SS')
	if content["author"] == "":
		content["author"] = "Dieser Text wurde von ganz vielen geschrieben... "
	else :
		content["author"] = common.escape_tex(content["author"])
	content["name"]=content["name"].upper()
	content["name"] = content["name"].replace(ur"ё", '"e').replace(u"Ё", '"E').replace(u"Ề", u"Ê\\hspace{-4mm}\\raisebox{2.5mm}{`}\\hspace{1.5mm}")
	if content["uid"] in smallnames:
		content["name"] = "\LARGE "+content["name"]
	elif content["uid"] in verysmallnames:
		content["name"] = "\large "+content["name"]
	if content["g8"]==1 :
		content["g8"] = "G8"
	elif content["g8"]==0 :
		content["g8"] = "G9"
	elif content["g8"]==2 :
		content["g8"] = "G8/G9 \\em{fixme}"
	
	if content["uid"] in smallmeta :
		content["metasize"] = "\\small \\vspace*{-1mm}"
	elif content["uid"] in verysmallmeta :
		content["metasize"] = "\\kathisize \\vspace*{-1mm}"
	else :
		content["metasize"] = ""

	content["avatar"] = "none.jpg"
	if os.path.isfile('tex/processed_peopleavatars/'+content["uid"]+'.jpg'):
		content["avatar"] = 'processed_peopleavatars/'+content["uid"]+'.jpg'
	
	content["lks"] = common.escape_tex(content["lks"] or "").strip()
	if content["lks"][0:6] == '(IM!) ':
		content["meisterpraep"] = "im"
		content["lks"] = content["lks"][6:-1]
	else:
		content["meisterpraep"] = "in"
	content["lebenswichtig"] = common.escape_tex(content["lebenswichtig"] or "")
	content["nachruf"] = common.escape_tex(content["nachruf"] or "")
	content["nachabi"] = common.escape_tex(content["nachabi"] or "")
	content["title"] = common.escape_tex(content["title"] or "")
	content["subtitle"] = common.escape_tex(content["subtitle"] or "")
	content["zukunft"] = common.escape_tex(content["zukunft"] or "")
	#print type(content["tags"])
	content["geb"] = dates[content["uid"][0:8]]
	content["tags"] = common.format_tags(content["tags"])
	
	if content["text"] != None:
		proc = subprocess.Popen("./md2tex.sh", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		content["text"] = proc.communicate(content["text"].encode("utf-8"))[0].decode("utf-8")
	else :
		content["text"] = spoiler;
	
	for s in sizes:
		if content["text"].find(s) != -1 :
			content["author"] = s+ " "+ content["author"]
			break 
	
	if os.path.isfile("temp/special/"+pupil["uid"]+".tex") :
		special = TeXTemplate(open("temp/special/"+pupil["uid"]+".tex").read().decode("utf-8"))
		content["special"] = special.substitute(content)
		content["text"] = ""
	
	
	
	out = page.substitute(content)
	#out = out
	f =  open("tex/pupils/" + pupil["uid"] + ".tex", "w")
	f.write(out.encode("utf-8"))
print "%i Schüler, %i mit email"%(len(pupillist), emails)
pupillist.sort()
f =  open("tex/pupilspages.tex", "w")
for p in pupillist :
	f.write("\input{pupils/" + p + ".tex}\n");
