import ../grapher
import ../graph/draw,../graph/funcs
import math,sequtils

let xx = linspace(0.0, 2*Pi, 0.1) 

# Create the surface with a plot in blue
var srf = plotXY(xx,sin(xx),Blue)

# Draw a cos over the surface
srf.drawFunc(xx,cos(xx), Purple)

# Save to file
srf.saveTo("example2.png")
