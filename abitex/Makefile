SRC = abi
all: fetchpupils fetchcourses pupils courses pdf

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


view :
	evince tex/abi.pdf& 3> /dev/null
	#./tex.sh
	#cd tex
	#make
	#bibtex $(SRC).aux
	#bibtex $(SRC).aux
	#pdflatex --file-line-error-style $(SRC).tex
	#pdflatex --file-line-error-style $(SRC).tex
