Graph
=====

This is a toy plotting library, written in [nim](http://nim-lang.org) and based on nimage.  
The end goal is to have a tiny plotting lib to include in [inim](https://github.com/stisa/INim)  
Outputs a `.png` file.

A copy of [npng](https://github.com/stisa/npng) is required for this to work.
( Just clone npng and then run `nimble install` in npng folder )
  
Some examples are inside [examples](examples):

### Example 1
![lines](examples/example1.png)


### Example 2
![sines](examples/example2.png)

## Current structure
- **grapher**: exposes linspace, plotXY and saveSurfaceTo ( basic functionality )

Inside `graph` there are specific apis:
- color: exposes various colours and the proc `color(r,g,b,a)`
- draw: drawing, so `line(x,y,x1,y1,color)`, functions to draw Axis, procs, etc
- plot: the implementation of `Surface` and `Axis`
- funcs: misc functions and linspace
