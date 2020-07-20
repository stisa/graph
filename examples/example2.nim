import ../src/graph
import ../src/graph/draw,../src/graph/funcs
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
