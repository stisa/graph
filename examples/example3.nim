import ../graph, math, sequtils

proc exp (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    exp(x)


let xx = linspace(0.001, Pi, 0.1)
var srf = initSurface(0,40,-120,240)
let scale = 320/240
srf.fillWith(White)
srf.drawAxis(10)
echo exp(xx)[^1]
srf.drawFunc(xx,exp(xx), Purple,Lines,10,10)
srf.drawProc(xx, proc(x:float):float=ln(x),Green,Lines,10,10)

srf.saveSurfaceTo("example3.png")
