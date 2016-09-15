import ../graph 
import math,sequtils

proc sin (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    sin(x)

proc cos (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    cos(x)

let xx = linspace(-Pi, Pi, 0.01)
var srf = drawXY(xx,sin(xx),Blue,Lines,100)
srf.drawFunc(xx,cos(xx), Green,Lines,100)
srf.saveSurfaceTo("example2.png")