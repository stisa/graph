import ../graph, math, sequtils

proc exp (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    exp(x)


let xx = linspace(0.001, Pi, 0.1)
let yy = exp(xx)
var srf = initSurface(0,320,-240,240)
let scale = 320/max(xx)
let yscale = 240/(max(yy))
srf.fillWith(White)
srf.drawAxis(10)
srf.drawFunc(xx,yy, Purple,Lines,scale,yscale)
srf.drawProc(xx, proc(x:float):float=ln(x),Green,Lines,scale,yscale)

srf.saveSurfaceTo("example3.png")
