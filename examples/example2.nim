import ../graph 
import math,sequtils

proc sin (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    sin(x)

proc cos (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    cos(x)

proc ln(x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    if x==0: ln(0.001)
    else: ln(x)
proc exp(x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    exp(x)

let xx = linspace(0.0, 2*Pi, 0.1)

var srf = drawXY(xx,exp(xx),Blue,Lines,10)
srf.drawFunc(xx,sin(xx), Green,Lines,10)
#echo ln(xx)
#srf.drawFunc(xx,ln(xx), Purple,Lines,10)
#srf.drawProc(xx,proc(x:float):float=exp(x),Red,Lines,10)

srf.saveSurfaceTo("example2.png")