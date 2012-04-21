SRC = abi
all:
	xelatex --file-line-error-style $(SRC).tex
	#bibtex $(SRC).aux
	#bibtex $(SRC).aux
	#pdflatex --file-line-error-style $(SRC).tex
	#pdflatex --file-line-error-style $(SRC).tex
bib: all
	bibtex $(SRC).aux
	#bibtex $(SRC).aux
	pdflatex --file-line-error-style $(SRC).tex
	pdflatex --file-line-error-style $(SRC).tex
