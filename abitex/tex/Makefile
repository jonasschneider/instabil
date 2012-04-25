SRC = abi
all:
	xelatex --file-line-error-style $(SRC).tex
	xelatex --file-line-error-style $(SRC).tex | grep "Package abitex Warning"
