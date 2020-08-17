import sequtils,math

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
    

proc linspace* [T](fm,to,step:T):seq[T] = toSeq(linsp(fm, to, step)) # Result and step should be same type, not all 4

proc sin* (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    sin(x)

proc exp*(a:openarray[float]):seq[float] =
  result = newSeq[float](a.len)
  for i,r in result.mpairs : r = exp(a[i])  
  
proc cos* (x:openarray[float]):seq[float] =
  result = map(x) do (x:float)->float : 
    cos(x)
