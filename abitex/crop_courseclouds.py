#!python2

import json, os, subprocess
import sys
import Image

f = open("courses.json")
blah = f.read()
j = json.loads(blah)

for course in j :
  id = course['id']
  infile = 'linked/courses/raw_clouds/'+id+'.png'
  outfile = 'linked/courses/clouds/'+id+'.png'

  print id

  if not os.path.isfile(outfile) or os.stat(infile).st_mtime > os.stat(outfile).st_mtime:
    im = Image.open(infile)
    s = im.size
    box = (30, 30, im.size[0]-30, im.size[1]-100)
    region = im.crop(box)
    region.save(outfile)