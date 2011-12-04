SRC = abi
all: fetchpupils fetchcourses avatars pupils courses pdf

fast : pupils courses pdf

dump :
	./dump.sh
	
clean:
	rm tex/abi.toc
	rm tex/abi.stc*
	rm tex/abi.pdf
	rm tex/abi.mtc*
	rm tex/abi.aux

fetchpupils:
	./fetchpupils.sh

pupils:
	./buildpupils.py

fetchcourses:
	./fetchcourses.sh

courses:
	./buildcourses.py

memoirs:
	./memoirs.py > tex/mems.tex
 
pdf: rev
	make -C tex
	
rev :
	./rev.py > tex/rev.tex

avatars:
	./fetchavas.py | sh

view :
	evince tex/abi.pdf& 2> /dev/null
	
push :
	cp tex/abi.pdf ftp
