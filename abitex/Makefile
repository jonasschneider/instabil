SRC = abi
all: fetchpupils spoiler pdf

fast : pupils pdf

dump :
	./dump.sh
	
clean:
	rm tex/abi.toc
	rm tex/abi.stc*
	rm tex/abi.pdf
	rm tex/abi.mtc*
	rm tex/abi.aux
	rm tex/pupils/*
	rm tex/pupilspages.tex

fetchpupils:
	./fetchpupils.sh

pupils:
	./buildpupils.py
	
spoiler:
	./buildpupils.py -s

fetchcourses:
	./fetchcourses.sh

courses:
	./buildcourses.py

memoirs:
	./memoirs.py > tex/mems.tex
 
pdf:
	make -C tex

avatars:
	./fetchavas.py | sh

view :
	evince tex/abi.pdf& 2> /dev/null
	
push :
	./push.sh

missing: fetchpupils
	./buildpupils.py | head -n -1 > users
	./qusers.py > missing
