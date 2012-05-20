#!/usr/bin/env python

import sys,os
from string import Template
import pollscommon as Poll


class TeXTemplate(Template) :
	delimiter = "#"
	
temp = TeXTemplate(open("temp/poll.tex").read())
ava_temp = "processed_peopleavatars/%s.jpg"

def getava(uid) :
	return ava_temp%uid if os.path.isfile("tex/"+(ava_temp%uid)) else "none.jpg"


lines = open("linked/umfragen.poll").readlines()
polls = []

avasizes = (20, 15, 11, 9, 5)

nicknames = Poll.parseNicks("linked/people/nicknames")

polls = Poll.parse(lines)
#print(polls)

#exit()

for poll in polls:
	
	d= {"caption"	: Poll.escape_tex(poll["caption"]),
		"lol"		: Poll.escape_tex("(%s)"%poll["lol"] if "lol" in poll else ""),
	}
		
	i = 0
	while i < len(poll["results"]) :
		d["n%s"%str(i+1)] = poll["results"][i][0]
		d["name%s"%str(i+1)] = ", ".join(tuple(map(lambda z: Poll.escape_tex(nicknames[z]), poll["results"][i][1])))
		size = avasizes[len(poll["results"][i][1])]
		d["ava%s"%str(i+1)] = "".join(tuple(map(lambda z: "\includegraphics[height=%imm]{%s}"%(size, getava(z)), poll["results"][i][1])))
		i+=1
	print(temp.substitute(d))
	#print(d)



