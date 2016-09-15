import ../graph 
import math,sequtils

proc sin (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    sin(x)

proc cos (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    cos(x)

let xx = linspace(0.0, 2*Pi, 0.1)
var srf = drawXY(xx,sin(xx),Blue,Lines,100,100)
srf.drawFunc(xx,cos(xx), Purple,Lines,100,100)

srf.saveSurfaceTo("example2.png")