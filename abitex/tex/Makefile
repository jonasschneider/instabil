SRC = personenberichte
all: persons memoirs

persons:
	xelatex --file-line-error-style $(SRC).tex
	xelatex --file-line-error-style $(SRC).tex | grep "Package abitex Warning" || true

memoirs:
	xelatex --file-line-error-style memoirs.tex
