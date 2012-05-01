#!/usr/bin/env python2
import os
os.system("pdfseparate tex/abi.pdf tex/prevu/abi-%d.pdf")
f = open("tex/pupilspages.tex")
i = 2
for l in f.readlines() :
	os.system("mv tex/prevu/abi-%i.pdf tex/prevu/abi-%s.pdf"%(i, l.strip()[14:-5]))
	i+=1
	print l.strip()[14:-5]
