import nimage/nimage except `[]`,`[]=`
import streams,sequtils,math

type 
  Surface* = object
    img : Image 
    width: int
    height: int
    origin: tuple[x0,y0:int] # origin relative to the middle of the surface
    xaxis : tuple[min,max:int] # the span on the x axis
    yaxis : tuple[min,max:int] # the span on the x axis
  Color* = NColor # An alias for NColor

const
  ## Common colors used for testing
  Transparent* = NColor(0x00000000)
  Black* = NColor(0x000000FF)
  Blue* = NColor(0x0000FFFF)
  Green* = NColor(0x00FF00FF)
  Red* = NColor(0xFF0000FF)
  Purple* = NColor(0xFF00FFFF)
  Yellow* = NColor(0xFFFF00FF)
  White* = NColor(0xFFFFFFFF)
  HalfTBlack* = NColor(0x00000088) ## HalfT<Color> colors are <color> at half alpha
  HalfTBlue* = NColor(0x0000FF88)
  HalfTGreen* = NColor(0x00FF0088)
  HalfTRed* = NColor(0xFF000088)
  HalftWhite* = NColor(0xFFFFFF88)
  
proc `[]`(sur:Surface, x,y:int):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  let
    cx = sur.img.width div 2
    cy = sur.img.height div 2    
  
  assert(cx+1 >= x)
  assert(cy+1 >= y)
  let translation = (cy-sur.origin.y0-y)*sur.img.width + x+cx+sur.origin.x0
  result = sur.img.data[translation]

proc `[]=`(sur: var Surface, x,y:int, color:Color) =  
  let
    cx = (sur.img.width-1) div 2
    cy = (sur.img.height-1) div 2
  let translation = (cy+((sur.origin.y0) div 2)-y)*sur.img.width + cx-(sur.origin.x0 div 2)+x
  sur.img.data[translation] = color

proc fillWith*(sur: var Surface,color:Color=White) =
  ## Loop over every pixel in `img` and sets its color to `color` 
  for pix in sur.img.data.mitems: pix = color 

proc saveSurfaceTo*(sur:Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  var file = newFileStream(filename, fmWrite)
  sur.img.save_png(file)
  file.close()

proc zip*[S, T](oa1: openarray[S], oa2: openarray[T]): seq[tuple[x: S, y: T]] =
  ## Returns a new sequence with a combination of the two input openarrays.
  ##
  ## For convenience you can access the returned tuples through the named
  ## fields `x` and `x`. If one sequence is shorter, the remaining items in the
  ## longer sequence are discarded, and a message is echoed.
  if oa1.len != oa2.len : echo "Some data got discarded when zipping."
  let m = min(oa1.len, oa2.len)
  newSeq(result, m)
  for i in 0 .. m-1: result[i] = (oa1[i], oa2[i])

type PlotMode* = enum
  Dots = 0
  Lines = 1

proc drawLine*(srf:var Surface, x1,y1,x2,y2:int, color : Color = Black) =
  ## Draws a line between x1,y1 and x2,y2. Uses Bresenham's line algorithm.
  var dx = x2-x1
  var dy = y2-y1
  
  let ix = if dx > 0 : 1 elif dx<0 : -1 else: 0
  let iy = if dy > 0 : 1 elif dy<0 : -1 else: 0

  dx = abs(dx) shl 1
  dy = abs(dy) shl 1

  var xi = x1
  var yi = y1

  srf[x1,y1] = color
  # This handles x>=0
  if dx>=dy:
    var err = dy-(dx shr 1)

  # Handle 1 and 4 quadrants 
    while xi != x2:
      if (err >= 0):
        err -= dx
        yi+=iy
      
      err += dy
      xi += ix
      srf[xi,yi] = color
#    elif x2-x1<0:
 #   # Handle 2 and 3 quadrants 
  #    while xi != x2:
   #     if (err >= 0 and (err == 1 or ix<0) ):
    #      err -= dx
     #     yi+=iy
      #  
       # err += dy
       # xi += ix
       # srf[xi,yi] = color
  else:
    var err = dx - (dy shr 1)
    while yi!=y2:
      if err >= 0:
        err -= dy
        xi += ix
      err += dx
      yi += iy
      srf[xi,yi] = color

proc flipX(srf:var Surface) =
# TODO: swap
  for c in 0..srf.width-1:
    for r in 0..floor((srf.height-1)/2).int :
      #swap(srf[c,r],srf[r,c]) error?
      let tmp = srf[r,c]
      srf[r,c] = srf[srf.height-r-1,c]
      srf[srf.height-r-1,c] = tmp

proc initSurface*(minx,maxx,miny,maxy:float):Surface =
  let dx = (maxx-minx)
  let dy = (maxy-miny)
  let xl = if dx mod 2 == 0 : dx+5 else: dx+4 # pad the surface a bit
  let yl = if dy mod 2 == 0 : dy+5 else: dy+4 

  let data = newSeq[Color]((xl.ceil.int) * (yl.ceil.int))
  result.img = Image(width: xl.ceil.int, height: yl.ceil.int, data: data)
  result.width = abs(dx).ceil.int
  result.height = abs(dy).ceil.int
  result.origin = ( abs(maxx.int)-abs(minx.int), abs(maxy.int)-abs(miny.int) )
  result.xaxis = (minx.int, maxx.int)
  result.yaxis = (miny.int, maxy.int)

proc drawAxis*(sur: var Surface, step:int=1,color:Color=Black) =
  sur.drawLine(sur.xaxis.min,0,sur.xaxis.max,0,color)
  sur.drawLine(0,sur.yaxis.min,0,sur.yaxis.max,color)

  for x in countup(sur.xaxis.min,sur.xaxis.max,step):
    if x != sur.xaxis.min and x != sur.xaxis.max : sur.drawLine(x,-1,x,1,color)
  for y in countup(sur.yaxis.min,sur.yaxis.max,step):
    if y != sur.yaxis.min and y != sur.yaxis.max : sur.drawLine(-1,y,1,y,color)

proc drawXY*(x,y:openarray[float], lncolor:Color=Black, mode:PlotMode=Dots, scale:float=1, bgColor:Color = White ):Surface =
  result = initSurface( scale*min(x), scale*max(x), scale*min(y), scale*max(y) )
  result.fillWith(bgColor)
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  let axis = if x.len>y.len: y.len else: x.len
  result.drawAxis(5)
  
  if mode == Dots:
    for i in 0..axis-1: result[(scale*x[i]).int,(scale*y[i]).int] = lncolor # HACK: trick with ^ to avoid flipping
  elif mode == Lines:
    for i in 0..<axis-2:      
      result.drawLine((scale*x[i]).int, (scale*y[i]).int, (scale*x[i+1]).int, (scale*y[i+1]).int, lncolor)
    result.drawLine((scale*x[^2]).int, (scale*y[^2]).int, (scale*x[^1]).int, (scale*y[^1]).int, lncolor)

proc drawFunc*(sur:var Surface, x,y:openarray[float], lncolor:Color=Black, mode:PlotMode=Dots, scale:float=1 ) =
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  let axis = if x.len>y.len: y.len else: x.len
  
  if mode == Dots:
    for i in 0..axis-1: sur[(scale*x[i]).int,(scale*y[i]).int] = lncolor # HACK: trick with ^ to avoid flipping
  elif mode == Lines:
    for i in 0..<axis-2:
      sur.drawLine((scale*x[i]).int, (scale*y[i]).int, (scale*x[i+1]).int, (scale*y[i+1]).int, lncolor)
    sur.drawLine((scale*x[^2]).int, (scale*y[^2]).int, (scale*x[^1]).int, (scale*y[^1]).int, lncolor)

proc drawProc*[T](sur:var Surface, x:openarray[T], fn: proc(o:openarray[T]), lncolor:Color=Black, mode:PlotMode=Dots,scale:float=1) {.inline.} =
  drawFunc(sur,x,fn(x),lncolor,mode,scale)

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
    
proc linspace* [T](fm,to,step:T):seq[T] = toSeq(linsp(fm, to, step))
    

when isMainModule:
  proc cos (x:openarray[float]):seq[float] =
    result = map(x) do (x:float)->float : 
      cos(x)

  let xx = linspace(-Pi, Pi, 0.01)
  var srf = drawXY(xx,cos(xx),Blue,Lines,100)
  srf.saveSurfaceTo("plot.png")