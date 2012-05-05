#!/usr/bin/env python2

import json, os, subprocess
f = open("courses.json")
blah = f.read()
j = json.loads(blah)
import codecs

f = codecs.open("linked/courses/tags.csv", "w", "utf-8")

def format_tag(tag):
    return tag.replace(' ', '~')

for course in j :
  s = ' '.join(map(format_tag, course['tags']))
  f.write(course['id'] + "|" + s + "\n");

f.close()