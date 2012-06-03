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
  outfile = 'tex/courseclouds/'+id+'.jpg'

  print id

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
    realbox = 0, bbox[1]-40, noborder.size[0]-1, bbox[3]
  print bbox, realbox
  trimmed = noborder.crop(realbox)

  wanted_width = 1.8 * im.size[1]
  padding = int(max(0, wanted_width-trimmed.size[0]))

  print 'want', wanted_width, 'got', trimmed.size[0], 'padding by', padding

  padded = Image.new(trimmed.mode, (trimmed.size[0]+padding, trimmed.size[1]), 'white')
  padded.paste(trimmed, (padding / 2, 0))

  
  out = padded
  out.save(outfile)