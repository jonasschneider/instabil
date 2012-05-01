#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import re,json

f = open("memoirs.json")
blah = f.read()
memoirs = json.loads(blah)

def beautiy_quotation(text) :
	quotation  = ","
	out = ""
	text = text.replace("<i>", "\\emph{")
	text = text.replace("<em>", "\\emph{")
	text = text.replace("</em>", "}")
	text = text.replace("</i>", "}")
	text = text.replace("—", "--")

	text = text.replace("&nbsp;", "\\/")
	for c in text :
		if c != '"' :
			out += c
		else :
			if quotation == "," :
				out += quotation*2
				quotation = "`"
			else :
				out += "{}"+quotation*2
				quotation = ","
	return out
			

def parse_memoir(mem) :
	print ""
	#print "\\vspace{2mm}"
	print "\parbox{\\columnwidth}{"
	#print "\\rule{1cm}{}"
	#print "\\vspace{1.5mm}"
	#print mem["text"].encode("utf-8")
	left = True
	text = mem["text"].splitlines()
	for line in text :
		line = line.encode("utf-8")
		re1='(\\[.*?\\])'	# Square Braces 1
		rg = re.compile(re1,re.IGNORECASE|re.DOTALL)
		m = rg.search(line)
		if m :
			p = m.group(1)[1:-1]
			
			if left:
				#print "\\hangindent=0.7cm"
				#print "\\textsc{\\footnotesize "+p+"} ,,{}"+beautiy_quotation(line.split("]")[1].strip())+"{}``\\\\"
				print "\\say{"+p+"}{"+beautiy_quotation(line.split("]")[1].strip())+"}"
				
			else :
				print "\\raggedleft ,,"+beautiy_quotation(line.split("]")[1].strip())+"{}`` \\textsc{\\footnotesize "+p+"}\\\\"
			#left ^= True
		else :
			if "(" in line :
				print "\\emph{\\footnotesize "+beautiy_quotation(line)+"}\\\\"
				#left ^= True
			else :
				if line.strip() != "" :
					print "{" + (beautiy_quotation(line.strip())) + "}\\\\"
		#print "\\vspace{1mm}"
	
	if mem["person"] != "Jonas" and "[" not in mem["text"] and mem["person"].strip() != "":
		print "\\vspace*{-2em} \\begin{flushright} \\textsc{\\footnotesize --\\/"+mem["person"].encode("utf-8")+"}\\end{flushright}"
	
	print "\\ornament }"
memoirs.reverse()
i = 0
for n in memoirs :
	parse_memoir(n)
	"""if i == 10:
		break
	i+=1"""


