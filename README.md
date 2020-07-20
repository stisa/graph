Graph
=====

This is a basic plotting library, written in [nim](http://nim-lang.org) and based on nimage.  
The end goal is to have a tiny plotting lib to include in [jupyternim](https://github.com/stisa/jupyternim)  
Outputs a `.png` file.
  
Some examples are inside [examples](examples):

### Example 1
![lines](examples/example1.png)
```nim
import graph
from graph/funcs import exp

let xx = linspace(0.0,10,0.1)
var srf = plotXY(xx,exp(xx),Red,White)
srf.saveTo("example1.png")
```

### Example 2

![sines](examples/example2.png)
```nim
import graph,
       graph/draw,
       graph/funcs # has the sin(openarray):openarray def
import math

let xx = linspace(0.0, 2*Pi, 0.1) 

# Create the surface with a plot in blue
var srf = plotXY(xx,sin(xx),Blue)

# Draw a cos over the surface
srf.drawFunc(xx,cos(xx), Purple)

# Pass the proc (eg ``sin``) to be mapped to xx so that yy=sin(xx)
srf.plotProc(xx, sin, Green)

# Save to file
srf.saveTo("example2.png")
```

### Mapping procs
If you need operations not in [/funcs](), map them:
```nim
import math,sequtils
# Map ln to a seq:
proc ln(x:seq[float]):seq[float] =
  x.mapit(ln(it))
```
Alternatively, if you have a map `proc(T)->T`, you can just use
`plotProc`, see [example2](examples/example2.nim)

## Current structure
- **graph**: exposes linspace, plotXY and saveSurfaceTo ( basic functionality )

Inside `graph` there are specific apis:
- color: exposes various colours and the proc `color(r,g,b,a)`
- draw: drawing, so `line(x,y,x1,y1,color)`, functions to draw Axis, procs, etc
- plot: the implementation of `Surface` and `Axis`
- funcs: misc functions and linspace
