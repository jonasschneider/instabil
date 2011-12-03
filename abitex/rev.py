#!/usr/bin/env python2

f = open("revision")
t= []
lst = []
for l in f.readlines() :
	l = l.strip()
	if len(l) == 0 :
		lst.append(t)
		t=[]
	else :
		t.append(l)
if len(t) != 0:
	lst.append(t)
print "\\section{Revisionen}"
i = 0
for rev in lst :
	date = ""
	for x in rev :
		if x.strip()[0] == "#" :
			date=x[1:]
	print "\\subsection*{Revision %i (%s)}"%(len(lst)-i, date)
	print "\\begin{itemize}"
	i+=1
	for item in rev:
		if item.strip()[0] != "#" :
			print "\\item %s"%item
	print "\\end{itemize}\n"

print "\\newpage"
