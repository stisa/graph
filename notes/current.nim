import ../src/graph
import ../src/graph/draw,../src/graph/funcs
import math

let x = linspace(0.0, 10, 0.1) 

var srf = plotXY(x,sin(x),Blue)
srf.plotProc(x, cos, Red)

# Save to file
srf.saveTo("currentpng.png")
