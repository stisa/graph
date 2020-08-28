import 
  graph, examples
import math

let xx = linspace(0.0, 2*Pi, 0.1) 

# Create the surface with a plot in blue
var srf = plot(xx,sin(xx),Viridis.blue)

# Draw a cos over the surface
srf.plot(xx,cos(xx), Purple)

# Pass the proc (eg ``sinh``) to be mapped to xx so that yy=sin(xx)
srf.plot(xx, sinh, Viridis.green)

# Save to file
srf.saveTo("example2.png")
srf.saveTo("example2.svg")
