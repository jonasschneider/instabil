#!/usr/bin/env python
# -*- coding: utf-8 -*-
import re,json,random

memoirfiles = ("linked/memoirs/alle.json", "linked/memoirs/jonas.json")

import codecs

memoirs = []
for mf in memoirfiles :
	f = codecs.open(mf, "r", "utf-8")
	s = f.read()
	for m in json.loads(s) :
		memoirs.append(m)

#random.shuffle(memoirs)

def beautify_quotation(text) :
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
			

def parse_line(line) :
	line = line.strip()
	speaker = None
	ad = None
	begin = 0
	quote = False
	if line[0] == "[" : #someone said something, dialogue
		begin = line.find("]")+1
		speaker = line[1:begin-1]
		if line[begin] == "(": #ad
			oldbegin = begin
			begin = line.find(")")+1
			ad = line[oldbegin+1:begin-1]
			#print(ad)
		text = beautify_quotation(line[begin:].strip())
		if not ad:
			print("\\say{%s}{%s}"%(speaker, text))
		else :
			print("\\saya{%s}{(%s)}{%s}"%(speaker, ad, text))
	elif line[0] == "(" : #comment
		print("\\emph{\\footnotesize (%s)}\\\\"%beautify_quotation(line[1:-1].strip()))
	elif line[0] == "\"" : #quote
		print("{%s}\\\\"%beautify_quotation(line.strip()))
		quote = True
	else: #statement
		print("{%s}\\\\"%beautify_quotation(line.strip()))
	return quote


for t in memoirs :
	#print(t)
	print("\parbox{\\columnwidth}{")
	quote = False
	for line in t["text"].splitlines() :
		if len(line) > 0:
			quote = parse_line(line)
	if quote :
		print("\\vspace*{-2em} \\begin{flushright} \\textsc{\\footnotesize --\\/%s}\\end{flushright}"%t["person"])

	print("\\ornament }")
	
