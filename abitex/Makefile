SRC = abi
all: fetchpupils pupils memoirs pdf

fast : pupils pdf

fetchpupils:
	./fetchpupils.sh

pupils:
	./buildpupils.py

memoirs:
	./memoirs.py > tex/mems.tex
 
pdf:
	make -C tex
	#./tex.sh
	#cd tex
	#make
	#bibtex $(SRC).aux
	#bibtex $(SRC).aux
	#pdflatex --file-line-error-style $(SRC).tex
	#pdflatex --file-line-error-style $(SRC).tex
