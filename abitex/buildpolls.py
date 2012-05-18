#!/usr/bin/env python

import sys,os
from string import Template



class TeXTemplate(Template) :
	delimiter = "#"
	
temp = TeXTemplate(open("temp/poll.tex").read())
ava_temp = "processed_peopleavatars/%s.jpg"

def getava(uid) :
	return ava_temp%uid if os.path.isfile("tex/"+(ava_temp%uid)) else "none.jpg"

def sortpoll(p) :
	p["results"] = sorted(p["results"], key=lambda z: int(z[0]), reverse=True)[:3]
	#p["results"] = p["results"][]
	return p

lines = open("linked/umfragen.poll").readlines()
polls = []

avasizes = (20, 15, 11, 9, 5)

def escape_tex(text) :
  return text.replace("♥", "<3").replace("☺", " :) ").replace("&#3232;", "{\\Tunga ಠ}").replace("&", "\\&").replace("#", "\\#").replace("_", "\\_").replace("^", "\^{}").replace("%", "\%").replace("✚", "{\\DjVu ✚}").replace("‿", "{\\DjVu ‿}").replace("✿", "{\\DjVu ✿}").replace("ё", '"e').replace("§nl§", "\\\\").replace("\\textbackslash\\/LaTeX", "\\LaTeX").replace("\\textbackslash\\/vspace", "\\vspace").replace("\\m/", "\\textbackslash m/").replace("♫", "\\twonotes").replace("\\>.</", "\\textbackslash>.</").replace("ё", "\"e")

nicknames = {}
for l in open("linked/people/nicknames").readlines() :
	z= tuple(map(str.strip, filter(lambda z: z!="",l.split("\t"))))
	nicknames[z[0]] = z[1]

for l in lines:
	l = l.strip().replace("\t", " ")
	if len(l) != 0:
		if l[0] == "#" :
			polls.append({"caption": l[1:], "results":[]})
		elif l[0] == "!" :
			polls[-1]["lol"] = l[1:].strip()
		elif l[0] == "%" :
			pass #comment
		else :
			if len(polls) == 0 :
				sys.exit(1)
			else :
				t = tuple(filter(lambda z: z!="",l.split(" ")))
				polls[-1]["results"].append((int(t[0]), t[1:]))
			
polls = list(map(sortpoll, polls))

#print(polls)

#exit()

for poll in polls:
	
	d= {"caption"	: escape_tex(poll["caption"]),
		"lol"		: escape_tex("(%s)"%poll["lol"] if "lol" in poll else ""),
	}
		
	i = 0
	while i < len(poll["results"]) :
		d["n%s"%str(i+1)] = poll["results"][i][0]
		d["name%s"%str(i+1)] = ", ".join(tuple(map(lambda z: escape_tex(nicknames[z]), poll["results"][i][1])))
		size = avasizes[len(poll["results"][i][1])]
		d["ava%s"%str(i+1)] = "".join(tuple(map(lambda z: "\includegraphics[height=%imm]{%s}"%(size, getava(z)), poll["results"][i][1])))
		i+=1
	print(temp.substitute(d))
	#print(d)



