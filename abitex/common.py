import os

def drafting():
  return os.path.exists('draftflag') and open('draftflag', 'r').read().strip() == "true"