#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import unicodedata

f = open("kurse.dat")
kurs = ""
def esc(foo) :
	return foo.replace("ö", "oe").replace("ß", "ss").replace("ü", "ue").replace("ä", "ae").replace(" ", "")

fixes = {
	"phanth": "phanthsa",
	"ahrensjo": "ahrensjo1",
	"halászev": "halaszev",
	"renkerjé": "renkerje",
	"tóthpa": "tothpa"
}

uids= []

kurse = {}

for k in f.read().split("!!newcourse!!") :
	lines = k.strip().split("\n")
	for l in lines :
		if l[:15] == './kurse/2012S4_' :
			kurs =l[15:-4] 
			kurse[kurs] = []
		else :
			name = l.strip().split("\t")[1].lower().split(", ")
			#print(esc(name[1])[:2])
			uid = esc(name[0])[:6] + esc(name[1])[:2]
			if uid in fixes:
				uid = fixes[uid]
			#print kurs + "\t" + uid
			if uid[:2] != "zz":
				kurse[kurs].append(uid)
print("[")
for k in kurse :
	print('{"%s": ["%s"]},'%(k, '","'.join(kurse[k])))
print("]")
