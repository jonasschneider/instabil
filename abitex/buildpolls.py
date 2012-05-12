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
	p["results"] = sorted(p["results"], key=lambda z: int(z[1]), reverse=True)[:3]
	#p["results"] = p["results"][]
	return p

lines = open("results.poll").readlines()
polls = []


nicknames = {}
for l in open("nicknames").readlines() :
	z= tuple(map(str.strip, filter(lambda z: z!="",l.split("\t"))))
	nicknames[z[0]] = z[1]

for l in lines:
	l = l.strip()
	if len(l) != 0:
		if l[0] == "#" :
			polls.append({"caption": l[1:], "results":[]})
		else :
			if len(polls) == 0 :
				sys.exit(1)
			else :
				polls[-1]["results"].append(tuple(filter(lambda z: z!="",l.split("\t"))))
			
polls = list(map(sortpoll, polls))

for poll in polls:
	
	d= {"caption"	: poll["caption"],
		"name1"		: nicknames[poll["results"][0][0]],
		"n1"		: poll["results"][0][1],
		"ava1"		: getava(poll["results"][0][0]),
		"name2"		: nicknames[poll["results"][1][0]],
		"n2"		: poll["results"][1][1],
		"ava2"		: getava(poll["results"][1][0]),
		"name3"		: nicknames[poll["results"][2][0]],
		"n3"		: poll["results"][2][1],
		"ava3"		: getava(poll["results"][2][0]),
		}
	print(temp.substitute(d))



