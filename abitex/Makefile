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
