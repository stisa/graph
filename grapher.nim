from npng import nil
import sequtils,math, os
import graph/plot
import graph/draw
import graph/funcs

export linspace

proc saveSurfaceTo*(sur:Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  var tmp = npng.initPNG(sur.width,sur.height,sur.pixels)
  npng.writeToFile(tmp,filename)
  
proc flipX(srf:var Surface) =
# TODO: swap
  for c in 0..srf.width-1:
    for r in 0..floor((srf.height-1)/2).int :
      #swap(srf[c,r],srf[r,c]) error?
      let tmp = srf[r,c]
      srf[r,c] = srf[srf.height-r-1,c]
      srf[srf.height-r-1,c] = tmp

#[proc drawFunc*(sur:var Surface, x,y:openarray[float], lncolor:Color=Black, mode:PlotMode=Lines, scale:float=1, yscale:float=1 ) =
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  let axis = if x.len>y.len: y.len else: x.len
  
  if mode == Dots:
    for i in 0..axis-1: sur[(scale*x[i]).int,(yscale*y[i]).int] = lncolor # HACK: trick with ^ to avoid flipping
  elif mode == Lines:
    for i in 0..axis-2: 
      sur.drawLine((scale*x[i]).int, (yscale*y[i]).int, (scale*x[i+1]).int, (yscale*y[i+1]).int, lncolor)
    
proc drawXY*(x,y:openarray[float], lncolor:Color=Black, mode:PlotMode=Dots, scale:float=1,yscale:float=1, bgColor:Color = White ):Surface =
  result = initSurface( scale*min(x), scale*max(x), yscale*min(y), yscale*max(y) )

  result.fillWith(bgColor)
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  result.drawAxis(5)
  result.drawFunc(x,y,lncolor,mode,scale,yscale)

proc drawProc*[T](sur:var Surface, x:openarray[T], fn: proc(o:openarray[T]):openarray[T], lncolor:Color=Black, mode:PlotMode=Dots,scale:float=1,yscale:float=1) {.inline.} =
  drawFunc(sur,x,fn(x),lncolor,mode,scale,yscale)

proc drawProc*[T](sur:var Surface, x:openarray[T], fn: proc(o:T):T, lncolor:Color=Black, mode:PlotMode=Dots,scale:float=1,yscale:float=1) =
  let yy = map(x) do (x:T)->T:
    fn(x)
  drawFunc(sur, x, yy, lncolor, mode, scale, yscale)
]#

#[when isMainModule:
  var rt = initSurface( 0,10,0,10 )

  rt.fillWith(Yellow)
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  rt.drawLine(0,0,5,5,Red)
  rt.saveSurfaceTo("test.png")]#