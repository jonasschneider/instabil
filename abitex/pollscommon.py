def sortpoll(p) :
	p["results"] = sorted(p["results"], key=lambda z: int(z[0]), reverse=True)[:3]
	#p["results"] = p["results"][]
	return p

def parse(raw) :
	polls = []
	for l in raw:
		l = l.strip().replace("\t", " ")
		if len(l) != 0:
			if l[0] == "#" :
				polls.append({"caption": l[1:], "results":[]})
			elif l[0] == "!" :
				polls[-1]["lol"] = l[1:].strip()
			elif l[0] == "%" :
				pass #comment
			else :
				if len(polls) == 0 :
					sys.exit(1)
				else :
					t = tuple(filter(lambda z: z!="",l.split(" ")))
					polls[-1]["results"].append((int(t[0]), t[1:]))
			
	return list(map(sortpoll, polls))

def escape_tex(text) :
  return text.replace("♥", "<3").replace("☺", " :) ").replace("&#3232;", "{\\Tunga ಠ}").replace("&", "\\&").replace("#", "\\#").replace("_", "\\_").replace("^", "\^{}").replace("%", "\%").replace("✚", "{\\DjVu ✚}").replace("‿", "{\\DjVu ‿}").replace("✿", "{\\DjVu ✿}").replace("ё", '"e').replace("§nl§", "\\\\").replace("\\textbackslash\\/LaTeX", "\\LaTeX").replace("\\textbackslash\\/vspace", "\\vspace").replace("\\m/", "\\textbackslash m/").replace("♫", "\\twonotes").replace("\\>.</", "\\textbackslash>.</").replace("ё", "\"e")

def parseNicks(nicks) :
	nicknames = {}
	for l in open(nicks).readlines() :
		z= tuple(map(str.strip, filter(lambda z: z!="",l.split("\t"))))
		nicknames[z[0].lower()] = z[1]
	return nicknames
