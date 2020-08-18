import graph, math, arraymancer
let 
  x  = arange(0.0'f64, 10,0.1)
let y  = sin(x)
let y2 = cos(x)
var srf = plot(x.data,y.data, Viridis.blue, grid=true)
srf.plot(x.data, y2.data, Viridis.orange)
# Save to file
srf.saveTo("currentpng.png")
