import os
# -*- coding: utf-8 -*-

def drafting():
  return os.path.exists('draftflag') and open('draftflag', 'r').read().strip() == "true"

def escape_tex(text) :
  return text.replace(u"♥", "<3").replace(u"☺", " :) ").replace("&#3232;", u"{\\Tunga ಠ}").replace("&", "\\&").replace("#", "\\#").replace("_", "\\_").replace("^", "\^{}").replace(u"%", "\%").replace(u"✚", u"{\\DjVu ✚}").replace(u"‿", u"{\\DjVu ‿}").replace(u"✿", u"{\\DjVu ✿}").replace(u"ё", '"e').replace(u"§nl§", u"\\\\").replace("\\textbackslash\\/LaTeX", "\\LaTeX").replace("\\textbackslash\\/vspace", "\\vspace").replace("\\m/", "\\textbackslash m/").replace(u"♫", "\\twonotes").replace("\\>.</", "\\textbackslash>.</")

tagfixes = {"4f8b0655146fa40001000014" : "{\\Chinese %s}",
"4f9d12f52ca3a7000100004a" : "{\\Chinese %s}",
"4f96b816079d0500010000fd":"{\\Fixed %s}"}

def beautify_quotation(text) :
  quotation  = ","
  out = ""
  text = text.replace(u"—", "--")

  text = text.replace("&nbsp;", "\\/")
  for c in text :
    if c != '"' :
      out += c
    else :
      if quotation == "," :
        out += quotation*2
        quotation = "'"
      else :
        out += quotation*2
        quotation = ","
  return out

def format_tags(raw_tags):
  tags = []
  for t in raw_tags :
    if t[1] in tagfixes :
      tags.append(beautify_quotation(tagfixes[t[1]]%escape_tex(t[0])))
    else:
      if t[1] == "4fa15969829ee30001000033" :
        tags.append(u"$e^{\\mathrm{i}\\pi}=-1$; ,,schön''")
      elif t[1] == "4f92e2c11baeb6000100007d" :
        tags.append(escape_tex(beautify_quotation(t[0])).replace(u"λ", "$\\lambda$"))
      else:
        tags.append(escape_tex(beautify_quotation(t[0])))

  return " // ".join(tags)
