import ../graph
from ../graph/funcs import exp
let xx = linspace(0.0,10,0.1)
var srf = plotXY(xx,exp(xx),Blue,White)
srf.saveTo("example1.png")
