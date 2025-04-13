+++
date = '2019-03-13'
draft = false
title = 'Plotting Circular Bubble Graph in LaTeX'
tags = ['latex', 'programming']
categories = ['technical']
+++

When doing web-intelligence, you might need to visualize what's called inter-sentence similarity in a particular format.
I personally haven't found an official name for these kinds of graphs, so I just simply call them Circular Bubble
Graphs. 

During a university project we needed such a graph in our report, and I got the idea of automatically plotting it
through `gnuplot` and integrating it directly into our report with `gnuplottex`. You can see an example of the outcome
of the script.

![Sentence similarity bubble graph example](/sentence_similarity_graph_example.svg)

The script operates on a comma-seperated file (`.csv`). The data should be provided as a matrix of sentences assumed to
be symmetric, with the cells containing a real number from 0 to 1, indicating the similarity between the column and the
row. Because of this symmetric property, half of the matrix is ignored by the script. (It also ignores the diagonal,
since sentence `23` will always have a maximum similarity to sentence `23`. It would also be hard to plot that line)

The whole script can be seen below, but you can also download it as a file
[here](/sentence_similarity_graph.gnuplot). Make sure to set the `my_dataset` variable to your desired
dataset. Example matrix can be downloaded [here](/example_similarities.csv).

```bash
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
```

{{< centered image="/6616144.png" >}}
