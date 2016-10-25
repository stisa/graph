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

proc sin*(a:openarray[float]):seq[float] =
  result = newSeq[float](a.len)
  for i,r in result.mpairs : r = sin(a[i])  

proc exp*(a:openarray[float]):seq[float] =
  result = newSeq[float](a.len)
  for i,r in result.mpairs : r = exp(a[i])  
  