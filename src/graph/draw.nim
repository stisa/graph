import plot,./color
from sequtils import map

proc bresline*(srf:var Surface, x1,y1,x2,y2:int, color : Color = Red) =
  ## Draws a line between x1,y1 and x2,y2. Uses Bresenham's line algorithm.
  var dx = x2-x1
  var dy = y2-y1
  
  let ix = if dx > 0 : 1 elif dx<0 : -1 else: 0
  let iy = if dy > 0 : 1 elif dy<0 : -1 else: 0

  dx = abs(dx) shl 1
  dy = abs(dy) shl 1

  var xi = x1
  var yi = y1
  srf[yi,xi] = color
  
  if dx>=dy:
    var err = dy-(dx shr 1)
    while xi != x2:
      if (err >= 0):
        err -= dx
        yi+=iy
      
      err += dy
      xi += ix
      srf[yi,xi] = color
  else:
    var err = dx - (dy shr 1)
    while yi!=y2:
      if err >= 0:
        err -= dy
        xi += ix
      err += dx
      yi += iy
      srf[yi,xi] = color

proc line*(srf:var Surface, x1,y1,x2,y2:float, color : Color = Red) {.inline.} =

  srf.bresline(srf.x.pixelFromVal(srf.origin.x0+x1), srf.y.pixelFromVal(srf.origin.y0+y1),
              srf.x.pixelFromVal(srf.origin.x0+x2),srf.y.pixelFromVal(srf.origin.y0+y2), color)

proc drawTicks(sur:var Surface,color:Color=Black,every:float=10.0,yevery:float=10.0) =
  # every is a percentage of the width/height
  var ticks = int(float(sur.x.max.pixel-sur.x.min.pixel)/every)
  var last_at = 0.0
  var ticksize = abs((sur.y.max.val-sur.y.min.val)/float(sur.y.min.pixel-sur.y.max.pixel))*3
  var span = sur.x.max.val-sur.x.min.val

  for i in 1..<ticks:
    sur.line(last_at,sur.origin.y0-ticksize,last_at,sur.origin.y0+ticksize,color)
    last_at+=(span/every)
  
  ticksize = abs((sur.x.max.val-sur.x.min.val)/float(sur.x.max.pixel-sur.x.min.pixel))*3
  let yev = if yevery!=every: yevery else: every   
  ticks = int(float(sur.y.min.pixel-sur.y.max.pixel)/yev)
  span = sur.y.max.val-sur.y.min.val
  last_at = 0.0

  for i in 1..<ticks:
    sur.line(sur.origin.x0-ticksize,last_at,sur.origin.x0+ticksize,last_at,color)
    last_at+=(span/yev)

proc drawAxis*(sur: var Surface, tickperc,ytickprc:float=10.0,color:Color=Black) =
  sur.line(sur.x.min.val,sur.origin.y0,sur.x.max.val,sur.origin.y0,color)
  sur.line(sur.origin.x0,sur.y.min.val,sur.origin.x0,sur.y.max.val,color)
  let ystep = if ytickprc!=tickperc : ytickprc else: tickperc
  sur.drawTicks(color,tickperc,ystep)

proc drawFunc*(sur:var Surface, x,y:openarray[float], lncolor:Color=Red) =
  ## Draw array of points (x,y) with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  let axis = if x.len>y.len: y.len else: x.len
  for i in 0..<axis-1: 
    sur.line(x[i],y[i], x[i+1], y[i+1], lncolor)
  
proc plotXY*(x,y:openarray[float], lncolor:Color=Red, bgColor:Color = White, origin:tuple[x0,y0:float]=(0.0,0.0)):Surface =
  ## Inits a surface and draws array points (x,y) to it. Returns the surface.
  let xa = initAxis(min(x),max(x),origin.x0)
  let ya = initAxis(min(y),max(y),origin.y0)

  result = initSurface( xa,ya, 320,240 ) # TODO: dehardcode

  result.fillWith(bgColor)
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  result.drawAxis()
  result.drawFunc(x,y,lncolor)

proc drawProc*[T](sur:var Surface, x:openarray[T], fn: proc(o:openarray[T]):openarray[T], lncolor:Color=Red) {.inline.} =
  drawFunc(sur,x,fn(x),lncolor)

proc drawProc*[T](sur:var Surface, x:openarray[T], fn: proc(o:T):T, lncolor:Color=Red) =
  let yy = map(x) do (x:T)->T:
    fn(x)
  drawFunc(sur, x, yy, lncolor)

when isMainModule:
  import nimPNG
  import funcs

  proc saveTo*(sur:Surface,filename:string) =
    ## Convience function. Saves `img` into `filename`
    var d=""
    for e in sur.pixels:
      d.add($e)
    discard savepng32(filename,d,sur.width,sur.height)
  
  let xx = linspace(0.0,10,0.1)
  var rt = plotXY(xx,exp(xx),Red,White)
  
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  #rt.drawLine(0,0,5,5,Red)
  rt.saveTo("tdraw.png")
