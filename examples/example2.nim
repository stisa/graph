import ../grapher
import ../graph/draw,../graph/funcs,../graph/color
import math,sequtils

proc sin (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    sin(x)

proc cos (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    cos(x)

let xx = linspace(0.0, 2*Pi, 0.1)
var srf = plotXY(xx,sin(xx),Blue)
srf.drawFunc(xx,cos(xx), Purple)

srf.saveSurfaceTo("example2.png")