SRC = abi
all: fetchpupils pupils pdf

fast : pupils pdf

dump :
	./dump.sh

fetchpupils:
	./fetchpupils.sh

pupils:
	./buildpupils.py

fetchcourses:
	./fetchcourses.sh

kursberichte:
	./buildcourses.py
	make kursberichte -C tex 

memoirs:
	./memoirs.py > tex/mems.tex
	make memoirs -C tex 
 
pdf:
	make persons -C tex 

avatars:
	./fetchavas.py | sh

deploy:
	cp tex/personenberichte.pdf  linked/personenberichte.pdf
	cp tex/memoirs.pdf  linked

prevu : spoiler pdf
	./prevu.py
