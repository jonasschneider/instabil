SRC = abi
all: fetchpupils pupils pdf

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
	make memoirs -C tex 
 
pdf:
	make persons -C tex 

avatars:
	./fetchavas.py | sh

view :
	evince tex/abi.pdf& 2> /dev/null
	
deploy:
	cp tex/personenberichte.pdf  linked/personenberichte.pdf
	cp tex/memoirs.pdf  linked

missing: fetchpupils
	./buildpupils.py | head -n -1 > users
	./qusers.py > missing
	
prevu : spoiler pdf
	./prevu.py
