import ./surface, ./color
from sequtils import map, zip

#[
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

proc drawTicks(sur:var Surface,color:Color=Black,every:float=10.0,yevery:float=10.0) =
  # every is a percentage of the width/height
  var ticks = int(float(sur.x.max.pixel-sur.x.min.pixel)/every)
  var last_at = 0.0
  var ticksize = abs((sur.y.max.val-sur.y.min.val)/float(sur.y.min.pixel-sur.y.max.pixel))*3
  var span = sur.x.max.val-sur.x.min.val

  for i in 1..<ticks:
    sur.line(last_at,sur.origin.y0-ticksize,last_at,sur.origin.y0+ticksize, 1.0, color)
    last_at+=(span/every)
  
  ticksize = abs((sur.x.max.val-sur.x.min.val)/float(sur.x.max.pixel-sur.x.min.pixel))*3
  let yev = if yevery!=every: yevery else: every   
  ticks = int(float(sur.y.min.pixel-sur.y.max.pixel)/yev)
  span = sur.y.max.val-sur.y.min.val
  last_at = 0.0

  for i in 1..<ticks:
    sur.line(sur.origin.x0-ticksize,last_at,sur.origin.x0+ticksize,last_at, 1.0, color)
    last_at+=(span/yev)

proc drawAxis*(sur: var Surface, tickperc,ytickprc:float=10.0,color:Color=Black) =
  sur.line(sur.x.min.val,sur.origin.y0,sur.x.max.val,sur.origin.y0, 1.0, color)
  sur.line(sur.origin.x0,sur.y.min.val,sur.origin.x0,sur.y.max.val, 1.0, color)
  let ystep = if ytickprc!=tickperc : ytickprc else: tickperc
  sur.drawTicks(color,tickperc,ystep)
]#

#### New way ideas:
# instead of directly plotting, save the x,y arrays. When asked to
# show the image, only then draw everything into the surface.
# this avoids problems with overlapping when using grid or box, since
# those are applied directly to the surface.
proc plot* [T:SomeFloat](sur: var Surface, x,y: openArray[T], col: Color=Viridis.orange) =
  assert(x.len == y.len)
  sur.plots.add((@x, @y, col, false))

proc plot* [T:SomeFloat](sur: var Surface, x: openArray[T],y:proc(x:T):T, col: Color=Viridis.orange) =
  let yy = map(x) do (x:T)->T:
    y(x)
  sur.plots.add((@x, @yy, col, false))

proc plot*(x,y: openarray[float], lncolor: Color = Viridis.blue, bgColor: Color = White,
              origin: tuple[x0,y0: float] = (0.0,0.0), padding= 20, 
              grid:bool=false, box:bool=true, ticks=true, size = [432,288]): Surface =
  ## Inits a surface and append points (x,y) to it. Returns the surface.
  let xa = initAxis(min(x),max(x),origin.x0, 0, size[0], padding)
  let ya = initAxis(min(y),max(y),origin.y0, 0, size[1], padding)

  result = initSurface(xa,ya)
  result.bg = bgColor
  if grid:
    result.drawgrid = true
  #result.drawAxis()
  if box:
    result.box(ticks=ticks)
  result.plot(x,y,lncolor)
