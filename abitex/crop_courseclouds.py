#!python2

import json, os, subprocess
import sys
import Image

f = open("courses.json")
blah = f.read()
j = json.loads(blah)

for course in j :
  id = course['id']

  print id

  im = Image.open('linked/courses/raw_clouds/'+id+'.png')
  s = im.size
  box = (30, 30, im.size[0]-30, im.size[1]-100)
  region = im.crop(box)
  region.save('linked/courses/clouds/'+id+'.png')