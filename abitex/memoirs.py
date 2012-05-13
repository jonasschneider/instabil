#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import re,json

memoirfiles = ("linked/memoirs/alle.json", "linked/memoirs/jonas.json")

memoirs = []
for mf in memoirfiles :
	for m in json.loads(open(mf).read()) :
		memoirs.append(m)


def beautiy_quotation(text) :
	quotation  = ","
	out = ""
	text = text.replace("<i>", "\\emph{")
	text = text.replace("<em>", "\\emph{")
	text = text.replace("<b>", "\\textbf{")
	text = text.replace("<tt>", "\\texttt{")
	text = text.replace("<strong>", "\\textbf{")
	text = text.replace("<h3>", "\\textsc{")
	
	text = text.replace("</em>", "}")
	text = text.replace("</i>", "}")
	text = text.replace("</b>", "}")
	text = text.replace("</tt>", "}")
	text = text.replace("</strong>", "}")
	text = text.replace("</h3>", "}")
	text = text.replace("—", "--")
	text = text.replace("$", "\$")
	text = text.replace("%", "\%")
	text = text.replace("<br>", "")
	text = text.replace("<br/>", "\\\\")

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
		re2='(\\(.*?\\))'	# Braces 1
		rg = re.compile(re1,re.IGNORECASE|re.DOTALL)
		#rg2 = re.compile(re2,re.IGNORECASE|re.DOTALL)
		m = rg.search(line)
		#m2 = rg2.search(line)
		if m :
			p = m.group(1)[1:-1]
			if left:
				#print "\\hangindent=0.7cm"
				#print "\\textsc{\\footnotesize "+p+"} ,,{}"+beautiy_quotation(line.split("]")[1].strip())+"{}``\\\\"
				if line.split("]")[1][0] != "(":
					print "\\say{"+p+"}{"+beautiy_quotation(line.split("]")[1].strip())+"}"
				else :
					print "\\saya{"+p+"}{("+line.split("]")[1].split(")")[0][1:]+")}{"+beautiy_quotation(line.split("]")[1].strip().split(")")[1].strip())+"}"
				
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


