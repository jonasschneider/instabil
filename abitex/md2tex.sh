#!/bin/sh
sed 's/~/\\ensuremath{\\sim}/' | pandoc -f markdown -t latex |  sed 's/\\subsubsection/\\subsubsection*/' |  sed -e 's/§§§//' | sed 's/\\subsection/\\subsubsection*/'  | sed "s/\[..\]//" | sed 's/\\begin{itemize}/\\begin{itemize*}/' | sed 's/\\end{itemize}/\\end{itemize*}/' |  sed 's/\\section/\\subsection*/' | sed -e 's/§§§//' | sed 's/§nl§/\\\\[\\baselineskip]/' | sed 's/§nl§/\\\\[\\baselineskip]/'  | sed 's/!``/!{}``/' | sed 's/!``/!{}``/' | sed 's/?``/?{}``/' | sed 's/?``/?{}``/' | sed 's/♥/<3/'| sed 's/♥/<3/' | sed 's/§cb§/{\\Chinese /' | sed 's/§ce§/}/' | sed 's/§fb§/{\\Fixed /' | sed 's/§\\{§/{/' | sed 's/§\\}§/}/' | sed 's/§\\ensuremath{\\sim}§/~/' | sed 's/☺/:)/'
