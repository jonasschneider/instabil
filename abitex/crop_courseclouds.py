#!python2

import json, os, subprocess
import sys
import Image
from PIL import ImageChops, ImageOps, ImageEnhance

import common

f = open("courses.json")
blah = f.read()
j = json.loads(blah)

for course in j :
  id = course['id']
  infile = 'linked/courses/raw_clouds/'+id+'.png'
  if common.drafting():
    outfile = 'linked/courses/clouds/'+id+'.jpg'
  else:
    outfile = 'linked/courses/clouds/'+id+'.png'

  print id

  if not os.path.isfile(outfile) or os.stat(infile).st_mtime > os.stat(outfile).st_mtime:
    im = Image.open(infile)
    im = im.convert('L')
    s = im.size
    box = (50, 50, im.size[0]-50, im.size[1]-100)
    noborder = im.crop(box)
    bg = Image.new(noborder.mode, noborder.size, 'black')
    mask = ImageChops.add(noborder, bg, 1, 100)
    mask = ImageChops.invert(mask)
    bbox = mask.getbbox()
    if bbox == None:
      realbox = 0, 0, noborder.size[0]-1, 100
    else:
      realbox = 0, bbox[1]-40, noborder.size[0]-1, bbox[3]+40
    print bbox, realbox
    trimmed = noborder.crop(realbox)

    mask = ImageChops.add(trimmed, bg, 1, 100)
    mask = ImageChops.invert(ImageEnhance.Contrast(mask).enhance(30.0))

    if not common.drafting():
      trimmed.putalpha(mask)
    trimmed.save(outfile)