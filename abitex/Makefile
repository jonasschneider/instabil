LATEX := xelatex --file-line-error-style
INCLUDES := tex/header.tex tex/seite.tex tex/generic.tex tex/course.tex tex/poll.tex
TARGETS := tex/personenberichte.pdf tex/kursberichte.pdf tex/memoirs.pdf tex/umfragen.pdf
all: $(TARGETS)

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

tex/courses.tex: courses.json buildcourses.py temp/course.tex linked/courses/clouds pupils.json course_members.json linked/courses/grouppics draftflag common.py
	./buildcourses.py

tex/mems.tex: memoirs.py draftflag common.py
	./memoirs.py > tex/mems.tex

tex/polls.tex: linked/people/nicknames linked/umfragen.poll buildpolls.py temp/poll.tex
	python2 buildpolls.py > tex/polls.tex

tex/personenberichte.pdf: tex/pupilspages.tex tex/personenberichte.tex tex/pupils/* $(INCLUDES) tex/processed_peopleavatars
	cd tex; $(LATEX) personenberichte.tex; cd ..
	cd tex; $(LATEX) personenberichte.tex | grep "Package abitex Warning"; cd ..

tex/kursberichte.pdf: tex/courses.tex tex/kursberichte.tex tex/courses/* $(INCLUDES) linked/courses/clouds linked/courses/grouppics
	cd tex; $(LATEX) kursberichte.tex; $(LATEX) kursberichte.tex; cd ..

tex/umfragen.pdf: tex/umfragen.tex tex/polls.tex
	cd tex; $(LATEX) umfragen.tex; cd ..

linked/courses/clouds: linked/courses/raw_clouds draftflag crop_courseclouds.py
	python2 crop_courseclouds.py
	touch linked/courses/clouds

tex/abizeitung.pdf: tex/abizeitung.tex
	# $(TARGETS)
	cd tex; $(LATEX) abizeitung.tex; cd ..

tex/memoirs.pdf: tex/mems.tex tex/memoirs.tex $(INCLUDES)
	cd tex; $(LATEX) memoirs.tex; cd ..

deploy:
	cp $(TARGETS) linked

linked/courses/grouppics: linked/courses/raw_grouppics/*
	for i in linked/courses/raw_grouppics/* ; do NEW=`echo $$i | sed 's/raw_grouppics/grouppics/g'`; convert $$i -colorspace Gray -brightness-contrast 5x25 -resize 50% $$NEW; done
	touch linked/courses/grouppics

tex/processed_peopleavatars: linked/people/avatars/*
	mkdir tex/processed_peopleavatars; true
	rm tex/processed_peopleavatars/*; true
	for i in `ls linked/people/avatars`; do echo $$i; NEW="tex/processed_peopleavatars/$$i"; convert linked/people/avatars/$$i -colorspace Gray -level-colors "#222222","#bbbbbb" +level-colors "#404040", $$NEW; done
	touch tex/processed_peopleavatars

course_members.json: mapcourses.py
	python2 mapcourses.py > course_members.json
