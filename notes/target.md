Goals
------
The goal is to have a very simple plotting library for 2d line plots, with an api modeled
after matlab and matplotlib.


## Target  

The reference style will be matplotlib-like, a goal is to be able to produce something matching:  

PNG:  

![targetpng.png](targetpng.png)

SVG:  

![targetsvg.svg](targetsvg.svg)

Those are produced by
```python
import matplotlib.pyplot as pp
import numpy as np
x = np.arange(0.0,10,0.1)
y1 = np.sin(x)
y2 = np.cos(x)
fig, ax = pp.subplots()
ax.plot(x,y1,x,y2)
ax.grid()
fig.savefig("targetpng.png")
fig.savefig("targetsvg.svg")
```

## Current
Currently we have:  

PNG:  

![currentpng.png](currentpng.png)

with:

```nim
import graph, math, arraymancer
let 
  x  = arange(0.0'f64, 10,0.1)
let y  = sin(x)
let y2 = cos(x)
var srf = plot(x.data,y.data, Viridis.blue)
srf.plot(x.data, y2.data, Viridis.orange)

# Save to file
srf.saveTo("currentpng.png")
```