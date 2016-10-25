import ../grapher
import ../graph/funcs,../graph/colors

let xx = linspace(0.0,10,0.1)
var srf = plotXY(xx,exp(xx),Red,White)
srf.saveSurfaceTo("example1.png")
