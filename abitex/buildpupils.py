#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import json, os, os.path
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
	return text.replace(u"♥", "<3").replace(u"☺", " :) ").replace("&#3232;", u"{\\Tunga ಠ}").replace("&", "\\&").replace("#", "\\#").replace("_", "\\_").replace("^", "\^{}").replace(u"%", "\%").replace(u"λ", "$\\lambda$").replace(u"✚", u"{\\DjVu ✚}").replace(u"‿", u"{\\DjVu ‿}").replace(u"✿", u"{\\DjVu ✿}").replace(u"ё", '"e').replace(u"§nl§", u"\\\\").replace("\\textbackslash\\/LaTeX", "\\LaTeX").replace("\\textbackslash\\/vspace", "\\vspace")

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

fixes = {"4f8b0655146fa40001000014" : "{\\Chinese %s}",
"4f9d12f52ca3a7000100004a" : "{\\Chinese %s}",
"4f96b816079d0500010000fd":"{\\Fixed %s}"}

smallnames = ("mahlerda", "burgerma", "hoffmelo")
verysmallnames = ("leikerch", "meissnna")

sizes = ("\\scriptsize", "\\kathisize", "\\footnotesize", "\\small")

print 'Namen zu lang:'
for pupil in j :
	page = Template(temp.decode("utf-8"))
	
	content = pupil["page"]
	content["special"] = ""
	
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
	print pupil["uid"]
	content["name"]=content["name"].upper().replace(u'ß', 'SS')
	if content["author"] == "":
		content["author"] = "Dieser Text wurde von ganz vielen geschrieben... "
	else :
		content["author"] = escape_tex(content["author"])
	content["name"]=content["name"].upper()
	content["name"] = content["name"].replace(u"ё", '"e').replace(u"Ё", '"E')
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
	content["lks"] = escape_tex(content["lks"] or "")
	content["lebenswichtig"] = escape_tex(content["lebenswichtig"] or "")
	content["nachruf"] = escape_tex(content["nachruf"] or "")
	content["nachabi"] = escape_tex(content["nachabi"] or "")
	content["title"] = escape_tex(content["title"] or "")
	content["subtitle"] = escape_tex(content["subtitle"] or "")
	#print type(content["tags"])
	content["geb"] = dates[content["uid"][0:8]]
	if content["tags"] != None and not options.spoiler:
		tags = []
		for t in content["tags"] :
			if t[1] in fixes :
				tags.append(beautiy_quotation(fixes[t[1]]%escape_tex(t[0])))
			else:
				if t[1] == "4fa15969829ee30001000033" :
					tags.append(u"$e^{\\mathrm{i}\\pi}=-1$; ,,schön''")
				else:
					tags.append(escape_tex(beautiy_quotation(t[0])))
		content["tags"] = " // ".join(tags)
		 
		 
	
	else : 
		content["tags"] = "Hier kommen Tags hin!"
	#content["tags"] = content["tags"].replace("%", "\\%")
	if content["text"] != None:
		proc = subprocess.Popen("./md2tex.sh", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		content["text"] = proc.communicate(content["text"].encode("utf-8"))[0].decode("utf-8")
	else :
		content["text"] = spoiler;
	
	for s in sizes:
		if content["text"].find(s) != -1 :
			content["author"] = s+ " "+ content["author"]
			break 
	
	if os.path.isfile("temp/"+pupil["uid"]+".tex") :
		special = Template(open("temp/"+pupil["uid"]+".tex").read().decode("utf-8"))
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
