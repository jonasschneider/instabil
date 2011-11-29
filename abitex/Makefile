SRC = abi
all: pupils memoirs pdftex

pupils:
	./buildpupils.py

memoirs:
	./memoirs.py > tex/mems.tex
 
pdftex:
	make -C tex
	#./tex.sh
	#cd tex
	#make
	#bibtex $(SRC).aux
	#bibtex $(SRC).aux
	#pdflatex --file-line-error-style $(SRC).tex
	#pdflatex --file-line-error-style $(SRC).tex
