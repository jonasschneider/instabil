#!/bin/sh
pandoc -f markdown -t latex | sed 's/\\subsection/\\subsubsection*/'  | sed "s/\[..\]//" | sed 's/\\begin{itemize}/\\begin{itemize*}/' | sed 's/\\end{itemize}/\\end{itemize*}/' | sed 's/§§§/{}/' | sed 's/\\section/\\subsection*/'
