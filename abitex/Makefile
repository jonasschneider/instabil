LATEX := xelatex --file-line-error-style
INCLUDES := tex/header.tex tex/seite.tex tex/generic.tex tex/course.tex
TARGETS := tex/personenberichte.pdf tex/kursberichte.pdf tex/memoirs.pdf
all: $(TARGETS)

fetch:
	./fetchpupils.sh
	./fetchcourses.sh
	./fetchmemoirs.sh
	heroku console "puts Course.all.map{|c|[c.id, c.subject, c.tags.map{|t|t.author.uid}.sort_by{rand}]}.to_json" | head -n 1 > tagauthors.json

draftflag:
	stat draftflag || echo 'false' > draftflag

tex/pupilspages.tex: pupils.json buildpupils.py temp/pupil.tex temp/special/*.tex draftflag common.py
	./buildpupils.py

tex/courses.tex: courses.json buildcourses.py temp/course.tex linked/courses/clouds pupils.json course_members.json linked/courses/grouppics draftflag common.py
	./buildcourses.py

tex/mems.tex: memoirs.json memoirs.py draftflag common.py
	./memoirs.py > tex/mems.tex

tex/personenberichte.pdf: tex/pupilspages.tex tex/personenberichte.tex tex/pupils/* $(INCLUDES)
	cd tex; $(LATEX) personenberichte.tex; cd ..
	cd tex; $(LATEX) personenberichte.tex | grep "Package abitex Warning"; cd ..

tex/kursberichte.pdf: tex/courses.tex tex/kursberichte.tex tex/courses/* $(INCLUDES) linked/courses/clouds linked/courses/grouppics
	cd tex; $(LATEX) kursberichte.tex; $(LATEX) kursberichte.tex; cd ..

linked/courses/clouds: linked/courses/raw_clouds draftflag crop_courseclouds.py
	python2 crop_courseclouds.py
	touch linked/courses/clouds

tex/memoirs.pdf: tex/mems.tex tex/memoirs.tex $(INCLUDES)
	cd tex; $(LATEX) memoirs.tex; cd ..

deploy:
	cp $(TARGETS) linked

linked/courses/grouppics: linked/courses/raw_grouppics/*
	#convert <input> -colorspace Gray <output>
	for i in linked/courses/raw_grouppics/* ; do NEW=`echo $$i | sed 's/raw_grouppics/grouppics/g'`; convert $$i -colorspace Gray -brightness-contrast 5x25 -resize 50% $$NEW; done
	touch linked/courses/grouppics

linked/people/avatar_thumbs:
	for i in linked/people/avatars/* ; do echo $$i; NEW=`echo $$i | sed 's/avatars/avatar_thumbs/g'`; convert $$i -resize 600x600 $$NEW; done
	touch linked/people/avatar_thumbs

course_members.json: mapcourses.py
	python2 mapcourses.py > course_members.json