#!/usr/bin/env python2
import random, os, math,os.path

edgedelta = 5

def step(dir) :
	if dir :
		delta = edgedelta
	else :
		delta = -edgedelta
	return " %i,%i "%(edgedelta, delta)

def randstep(n) :
	return step(n >= random.random())

x = 50
while x<1000 :
	i = 0
	out = "m 0,%i "%(x+random.randint(-5, 5))
	while i < 20 :
		out += " %i,%i "%(random.randint(20, 50), 0)
		#out += randstep(x/1000.0)
		out += randstep(.5)
		i+=1
	out += " %i,%i "%(random.randint(20, 50), 0)
	print ' <path inkscape:connector-curvature="0"\
       id="path%i"\
       d="%s"\
       style="color:#000000;fill:none;stroke:#ffffff;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate" />'%(x,out)
	#print out
	x+=10
