LATEX := xelatex --file-line-error-style
INCLUDES := tex/header.tex tex/seite.tex tex/generic.tex
TARGETS := tex/personenberichte.pdf tex/kursberichte.pdf tex/memoirs.pdf
all: $(TARGETS)

fetch:
	./fetchpupils.sh
	./fetchavas.py | sh
	./fetchcourses.sh
	./fetchmemoirs.sh

tex/pupilspages.tex: pupils.json buildpupils.py temp/*.tex
	./buildpupils.py

tex/courses.tex: courses.json buildcourses.py temp/course.tex
	./buildcourses.py

tex/mems.tex: memoirs.json memoirs.py
	./memoirs.py > tex/mems.tex

tex/personenberichte.pdf: tex/pupilspages.tex tex/personenberichte.tex tex/pupils/* $(INCLUDES)
	cd tex; $(LATEX) personenberichte.tex; cd ..
	cd tex; $(LATEX) personenberichte.tex | grep "Package abitex Warning"; cd ..

tex/kursberichte.pdf: tex/courses.tex tex/kursberichte.tex tex/courses/* $(INCLUDES) linked/courses/clouds
	cd tex; $(LATEX) kursberichte.tex; cd ..

linked/courses/clouds: linked/courses/raw_clouds/*
	python2 crop_courseclouds.py

tex/memoirs.pdf: tex/mems.tex tex/memoirs.tex $(INCLUDES)
	cd tex; $(LATEX) memoirs.tex; cd ..

deploy:
	cp $(TARGETS) linked