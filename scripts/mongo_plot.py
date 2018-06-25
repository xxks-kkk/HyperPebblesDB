"""
========
Barchart
========

A bar plot with errorbars and height labels on individual bars
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties

fontP = FontProperties()
fontP.set_size('small')

N = 8
men_means = (20, 35, 30, 35, 27)
men_std = (2, 3, 4, 1,2)

p = 8*[1]
hp = [1.03203313, 0.9140257571, 0.9651474531, 0.9976557853, 0.762728146, 0.6974782968, 1.109484957, 0.5001654169]
wt = [0.3806833702, 0.661047866, 0.6822135358, 1.009516812, 0.4937560038, 0.3832988838, 1.372514023, 1.70009925]
rocks = [0.2648202412, 0.7803393257, 0.9285962794, 0.96838809, 0.6897214217, 0.5202015035, 1.244212137, 1.179477283]

ind = np.arange(N)  # the x locations for the groups
width = 0.15        # the width of the bars

fig, ax = plt.subplots()
rects1 = ax.bar(ind, p, width, color='r', hatch='*')
rects2 = ax.bar(ind + width, hp, width, color='y', hatch="+")
rects3 = ax.bar(ind + 2*width, wt, width, color='b',  hatch="/")
rects4 = ax.bar(ind + 3*width, rocks, width, color='g', hatch="O")

# add some text for labels, title and axes ticks
ax.set_ylabel('Ratio wrto PebblesDB')
ax.set_xticks(ind + width / 3)
ax.set_xticklabels(('A', 'B', 'C', 'D', 'E', 'F', 'Load A', 'Load E'))
for tick in ax.get_xticklabels():
    tick.set_rotation(-45)

ax.legend((rects1[0], rects2[0], rects3[0], rects4[0]), ('PebblesDB', 'HyperPebblesDB', 'WiredTiger', 'RocksDB'), loc='best fit', prop=fontP)

plt.show()
