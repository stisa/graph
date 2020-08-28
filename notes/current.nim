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