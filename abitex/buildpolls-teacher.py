#!/usr/bin/env python

import sys,os
from string import Template
import pollscommon as Poll


class TeXTemplate(Template) :
	delimiter = "#"
	
temp = TeXTemplate(open("temp/poll-teacher.tex").read())


lines = open("linked/lehrer.poll").readlines()
polls = []


nicknames = Poll.parseNicks("linked/lehrer.nicks")

polls = Poll.parse(lines)
#print(polls)

#exit()

tikztemp = "\\draw[fill=lightgray] (0,%(off)f) node[below left=-2pt] {\\footnotesize (%(n)i)} rectangle +(%(l)f,-.5); \\node[above right=-7pt] at (0,%(off_t)f) {\\hspace{1pt} \\small %(label)s};\n"

for poll in polls:
	
	d= {"caption"	: Poll.escape_tex(poll["caption"]),
		"lol"		: Poll.escape_tex("(%s)"%poll["lol"] if "lol" in poll else ""),
		"tikz"		: ""
	}
	i = 0
	while i < len(poll["results"]) :
		#d["n%s"%str(i+1)] = poll["results"][i][0]
		#d["name%s"%str(i+1)] = ", ".join(tuple(map(lambda z: Poll.escape_tex(nicknames[z]), poll["results"][i][1])))
		n=poll["results"][i][0]
		d["tikz"] += tikztemp%{
			"off"	:-(.5+1.5*i),
			"n"		:n,
			"off_t"	:-(1.5+1.5*i),
			"label"	:", ".join(tuple(map(lambda z: Poll.escape_tex(nicknames[z]), poll["results"][i][1]))),
			"l"		:float(n)/10}
		i+=1
	print(temp.substitute(d))
	#print(d)



