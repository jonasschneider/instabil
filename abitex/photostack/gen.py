#!/usr/bin/env python2
import random, os, math
from PIL import Image
offset_x = 150
offset_y = 150
step_x = 200
step_y = 150
n_x = 3
n_y = 6

x = 0
y = 0
pos_rand_range = 10

targetsize = 40000
size_rand_range = 3000

angle_rand_range = 5

def calcsize((x,y), target) :
	size = x*y
	factor = math.sqrt(size/target)
	return (int(x/factor), int(y/factor))
	

path = "/home/lukas/Dropbox/Studienfahrt Barcelona/Bilder Lisa"
imgs = os.listdir(path)
random.shuffle(imgs)
iimg = 0
#print calcsize(Image.open(path + "/" + imgs[0]).size, targetsize)
out = []
while x < n_x :
	y=0
	while y < n_y :
		pos_x = offset_x + x*step_x + random.randint(-pos_rand_range, pos_rand_range)
		pos_y = offset_y + y*step_y + random.randint(-pos_rand_range, pos_rand_range)
		size = calcsize(Image.open(path + "/" + imgs[iimg]).size, targetsize+random.randint(-size_rand_range, size_rand_range))
		img_x = pos_x - (size[0]/2)
		img_y = pos_y - (size[1]/2)
		rot = random.randint(-angle_rand_range, angle_rand_range)
		#print size
		out.append('<g id="g'+str(iimg)+'"><image y="' +str(img_y)+ '"    x="' +str(img_x)+ '"\
       id="image'+str(x)+str(y)+'"\
       xlink:href="file://'+path + "/" + imgs[iimg]+'"\
       height="'+str(size[1])+'"\
       width="'+str(size[0])+'" \
       transform="rotate('+str(rot)+', '+str(pos_x)+', '+str(pos_y)+')"/><rect id="'+str(x)+str(y)+'" x="'+str(img_x)+'" y="'+str(img_y)+'" width="'+str(size[0])+'" height="'+str(size[1])+'" ry="0" style="fill:none;stroke:#ffffff;stroke-width:5;" transform="rotate('+str(rot)+', '+str(pos_x)+', '+str(pos_y)+')"/></g>')
		#print '<rect x="'+str(pos_x)+'" y="'+str(pos_y)+'" width="50" height="50" fill="#000000"/>'
		y+=1
		iimg += 1
	x+=1

random.shuffle(out)
for x in out :
	print x
