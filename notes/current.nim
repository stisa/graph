import graph
import math, sequtils, sugar

iterator linsp*[T](fm,to,step:T):T =
    if fm<to:
      var res: T = T(fm)
      while res<=to:
        yield res
        res+=step
    elif fm>to:
      var res: T = T(fm)
      while res>=to:
        yield res
        res-=step
    else:
      yield fm

proc arange* [T](fm,to,step:T):seq[T] = toSeq(linsp(fm, to, step)) # Result and step should be same type, not all 4


let 
  x = arange(0.0, 10, 0.1) 
  y = x.map(xx => sin(xx))

var srf = plotXY(x,y,Viridis.blue)
srf.plotProc(x, cos, Viridis.red)

# Save to file
srf.saveTo("currentpng.png")
