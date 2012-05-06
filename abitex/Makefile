LATEX := xelatex --file-line-error-style
all: tex/personenberichte.pdf tex/kursberichte.pdf tex/memoirs.pdf

pupils.json:
	./fetchpupils.sh

courses.json:
	./fetchcourses.sh

tex/pupilspages.tex: pupils.json buildpupils.py
	./buildpupils.py

tex/courses.tex: courses.json buildcourses.py
	./buildcourses.py

tex/mems.tex: memoirs.json
	./memoirs.py > tex/mems.tex

tex/personenberichte.pdf: tex/pupilspages.tex tex/personenberichte.tex
	cd tex; $(LATEX) personenberichte.tex; cd ..
	cd tex; $(LATEX) personenberichte.tex | grep "Package abitex Warning"; cd ..

tex/kursberichte.pdf: tex/courses.tex tex/kursberichte.tex
	cd tex; $(LATEX) kursberichte.tex; cd ..

tex/memoirs.pdf: tex/mems.tex tex/memoirs.tex
	cd tex; $(LATEX) memoirs.tex; cd ..

avatars:
	./fetchavas.py | sh

deploy:
	cp tex/personenberichte.pdf linked
	cp tex/memoirs.pdf linked
	cp tex/kursberichte.pdf linked