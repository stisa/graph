Graph
=====

This is a basic plotting library, written in [nim](http://nim-lang.org).  
The end goal is to have a tiny plotting lib to use with [jupyternim](https://github.com/stisa/jupyternim)  
Outputs `.png` or `.svg` files, or a string that contains the `png` as binary data or the `svg` as string.

For what I want to achieve and where I'm at, see [target](notes/target.md)

Some examples are in [examples](examples):

**Note: text labels are WIP, only for svg atm**

### Example 
![current](notes/currentsvg.svg)
```nim
import graph, math, arraymancer
let 
  x  = arange(0.0'f64, 10,0.1)
let 
  y  = sin(x)
  y2 = cos(x)
var srf = plot(x.data,y.data)
srf.plot(x.data, y2.data)
srf.grid
# Save to file
srf.saveTo("currentpng.png")
srf.saveTo("currentsvg.svg")
```

## Current structure
- **graph**: exposes everything ( basic functionality )

Inside `graph` there are specific apis:
- color: exposes various colours and the proc `color(r,g,b,a)`
- plot: initializing the plot, adding plots
- surface: the implementation of `Surface` and `Axis`
- `backend<x>`: handles rendering the plot

## TODO:

* matplotlib defaults
  - figure size is 6.4x4.8"
  - dpi is 100  
* [target style](notes/target.md)
* plotProc should lazily evaluate the proc?
* better integration with Arraymancer (a Concept that matches if .data and [] ?)
* integrate chroma? (need to contribute blend?)
* separate drawing layers for the plot and the background/names/etc so that lines aren't overwritten
* can I use Arraymancer's tensor without blas? Would they work in js?
* documentation
* looks like matplotlib does some spline/approximation stuff to get that smooth
  * nope, checked the svg and it's plain lines => I need a better line algo
* distinguish margin and padding
* calculate max/min y value str len and adjust eg left margin to fit labels
* svg backend: less strings, more nodes