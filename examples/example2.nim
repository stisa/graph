import 
  graph, examples
import math

let xx = linspace(0.0, 2*Pi, 0.1) 

# Create the surface with a plot in blue
var srf = plot(xx,sin(xx),Viridis.blue)

# Draw a cos over the surface
srf.drawFunc(xx,cos(xx), Purple)

# Pass the proc (eg ``sin``) to be mapped to xx so that yy=sin(xx)
srf.plot(xx, sin, Viridis.green)

# Save to file
srf.saveTo("example2.png")
