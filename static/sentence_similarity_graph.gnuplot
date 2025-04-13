# Copyright 2019 sillydan1
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Sentence similarity graph plotter
# uncomment this for manual operation of the dataset plotted
# my_dataset = "./sentence_similarities.csv" # ARG1
set parametric
set size square

# Styling
set pointsize 7.5
set style fill solid 1.0 border rgb 'grey30'
set style line 1 lc rgb 'black' pt 6 lw 0.5

# Basically a one-dimensional circular coordinate system
fx(t) = cos(t)
fy(t) = sin(t)
rownum = floor(system("wc -l ".my_dataset."")) +1
coord(k) = (k/real(rownum))*(2*pi)
fxx(t) = cos(coord(t))
fyy(t) = sin(coord(t))

set trange [0:2*pi-(coord(1.0))]
set sample rownum
set noborder
unset tics
set xrange [-1.2:1.2]
set yrange [-1.2:1.2]
set title "Sentence inter-similarity graph"
set multiplot
refloptimization = 0
do for [i = 0:rownum-1] {
	do for [j = refloptimization:rownum-1] {
		if (i != j) {
			# Get how many columns there are in the dataset.
			arrwidth = real(system("awk 'FNR == ".(i+1)." {print $".(j+1)."}' ".my_dataset.""))
			if (arrwidth > 0.0) {
				bubblerad = 0.125
				x1 = fxx(i)
				y1 = fyy(i)
				x2 = fxx(j)
				y2 = fyy(j)
				
				dvx = x2-x1
				dvy = y2-y1
				dvl = sqrt((dvx ** 2) + (dvy ** 2))
				x1 = x1 + (dvx/dvl)*bubblerad
				y1 = y1 + (dvy/dvl)*bubblerad
				x2 = x2 - (dvx/dvl)*bubblerad
				y2 = y2 - (dvy/dvl)*bubblerad
				# Overleaf's arrow-width rendering is pretty terrible, 
				# so we use a color-gradient to determine connection-strength.
				if (arrwidth > 0.2) { 
					col = "#000000" 
				} else { 
					if (arrwidth < 0.1) { 
						col = "#B8B8B8"
					} else { 
						col = "#E4E4E4" 
					} 
				}
				
				set arrow "".i.j."" from x1,y1 to x2,y2 nohead lw 0.5 lc rgb col
				#set label "H" at (fxx(j)-fxx(i)),(fyy(j)-fyy(i))
				show arrow "".i.j.""
			}
		}
	}
	refloptimization = refloptimization + 1
}
# Plot the circles
plot '+' u (fx(t)):(fy(t)) w p ls 1 notitle

# Plot the sentence labels
plot '+' u (fx(t)):(fy(t)):(sprintf("s.%d",$0+1)) with labels notitle
