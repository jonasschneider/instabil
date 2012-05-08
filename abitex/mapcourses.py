#!python
import json, os, subprocess, itertools, common, sys
from string import Template
course_members = json.loads(open("linked/courses/loe_coursemembers.json").read())
course_authors = json.loads(open("tagauthors.json").read())

found = {}

for course, subject, authors in course_authors:
  possibilities = {}

  right_subject = []

  normalized_subject = subject[:-1] if subject[-1] == 'b' else subject

  for candidate, members in course_members.iteritems():
    if candidate.find(normalized_subject) != -1:
      right_subject = right_subject + [[candidate, members]]

  for author in authors:
    for possible_course, course_authors in right_subject:
      if author in course_authors:
        if not possible_course in possibilities:
          possibilities[possible_course] = 0
        possibilities[possible_course] += 1
        for similar_author in authors:
          if similar_author in course_authors: 
            possibilities[possible_course] += 2

  if len(possibilities) > 0:
    guess = max(possibilities, key=possibilities.get)
    count = float(possibilities[guess])
    teh_sum = float(sum(possibilities.values()))
    authenticity = count / teh_sum * 100
    #print '%s (%s) is probably %s with %d%%'%(course, subject, guess, authenticity)
    found[course] = course_members[guess]
  else:
    print >> sys.stderr, '%s (%s) has no matches'%(course, subject)
print json.dumps(found)