LATEX := xelatex --file-line-error-style
INCLUDES := tex/header.tex tex/seite.tex tex/generic.tex tex/course.tex tex/poll.tex
TARGETS := tex/personenberichte.pdf tex/kursberichte.pdf tex/memoirs.pdf tex/umfragen.pdf
all: $(TARGETS)
ROOT := $(shell pwd)

latex = $(LATEX) $(1) | $(ROOT)/progress.rb

fetch:
	./fetchpupils.sh
	./fetchcourses.sh
	./fetchmemoirs.sh

tagauthors.json:
	heroku console "puts Course.all.map{|c|[c.id, c.subject, c.tags.map{|t|t.author.uid}.sort_by{rand}]}.to_json" | head -n 1 > tagauthors.json

draftflag:
	stat draftflag || echo 'false' > draftflag

tex/pupilspages.tex: pupils.json buildpupils.py temp/pupil.tex temp/special/*.tex draftflag common.py
	./buildpupils.py

tex/courses.tex: courses.json buildcourses.py temp/course.tex temp/kursbericht.tex tex/courseclouds pupils.json course_members.json tex/grouppics draftflag common.py
	./buildcourses.py

tex/mems.tex: memoirs.py draftflag common.py linked/memoirs/*.json
	./memoirs.py > tex/mems.tex

tex/polls.tex: linked/people/nicknames linked/umfragen.poll buildpolls.py pollscommon.py temp/poll.tex
	python buildpolls.py > tex/polls.tex
	
tex/polls-teacher.tex: linked/lehrer.nicks linked/lehrer.poll buildpolls.py pollscommon.py temp/poll-teacher.tex
	python buildpolls-teacher.py > tex/polls-teacher.tex

tex/personenberichte.pdf: tex/pupilspages.tex tex/personenberichte.tex tex/pupils/* $(INCLUDES) tex/processed_peopleavatars
	cd tex; $(call latex,personenberichte.tex) ; cd ..

tex/kursberichte.pdf: tex/courses.tex tex/kursberichte.tex tex/courses/* $(INCLUDES) tex/courseclouds tex/grouppics
	cd tex; $(call latex,kursberichte.tex); $(call latex,kursberichte.tex); cd ..

tex/umfragen.pdf: tex/umfragen.tex tex/polls.tex
	cd tex; $(LATEX) umfragen.tex; cd ..

tex/courseclouds: linked/courses/raw_clouds draftflag crop_courseclouds.py
	mkdir tex/courseclouds; true
	rm tex/courseclouds/*; true

	python2 crop_courseclouds.py
	touch tex/courseclouds

tex/abizeitung.pdf: tex/abizeitung.tex tex/mems.tex tex/generic.tex tex/polls.tex tex/polls-teacher.tex linked/imperial_news.tex linked/extracontent/*
	# $(TARGETS)
	cd tex; $(LATEX) abizeitung.tex; cd ..

tex/memoirs.pdf: tex/mems.tex tex/memoirs.tex $(INCLUDES)
	cd tex; $(LATEX) memoirs.tex; cd ..

deploy:
	cp $(TARGETS) linked

tex/grouppics: linked/courses/raw_grouppics/* process_grouppic
	mkdir tex/grouppics; true
	rm tex/grouppics/*; true
	for i in linked/courses/raw_grouppics/* ; do ./process_grouppic $$i; done
	touch tex/grouppics

tex/processed_peopleavatars: linked/people/avatars/*
	mkdir tex/processed_peopleavatars; true
	rm tex/processed_peopleavatars/*; true
	for i in `ls linked/people/avatars`; do echo $$i; NEW="tex/processed_peopleavatars/$$i"; convert linked/people/avatars/$$i -colorspace Gray -level-colors "#222222","#bbbbbb" +level-colors "#404040", $$NEW; done
	touch tex/processed_peopleavatars

course_members.json: mapcourses.py
	python2 mapcourses.py > course_members.json
