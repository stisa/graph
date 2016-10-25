import npng
import streams,sequtils,math, os

type 
  Color* = uint32
  Surface* = object
    img : PNG ## Todo: make this a seq of pixels, make tje api backend agnostic
    width: int
    height: int
    origin: tuple[x0,y0:int] # origin relative to the middle of the surface
    xaxis : tuple[min,max:int] # the span on the x axis
    yaxis : tuple[min,max:int] # the span on the x axis
    pixels: seq[Color]
    realh:int
    realw:int # affective width with padding and all
  
const
  ## Common colors used for testing
  Transparent* = Color(0x00000000)
  Black* = Color(0x000000FF)
  Blue* = Color(0x0000FFFF)
  Green* = Color(0x00FF00FF)
  Red* = Color(0xFF0000FF)
  Purple* = Color(0xFF00FFFF)
  Yellow* = Color(0xFFFF00FF)
  White* = Color(0xFFFFFFFF)
  HalfTBlack* = Color(0x00000088) ## HalfT<Color> colors are <color> at half alpha
  HalfTBlue* = Color(0x0000FF88)
  HalfTGreen* = Color(0x00FF0088)
  HalfTRed* = Color(0xFF000088)
  HalftWhite* = Color(0xFFFFFF88)
  
proc `[]`(sur:Surface, x,y:int):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  
  let
    cx = sur.realw div 2
    cy = sur.realh div 2    
  
  assert(cx+1 >= x)
  assert(cy+1 >= y)
  let translation = (cy-sur.origin.y0-y)*sur.realw + x+cx+sur.origin.x0
  result = sur.pixels[translation]

proc `[]=`(sur: var Surface, x,y:int, color:Color) =  
  let
    cx = sur.realw div 2
    cy = sur.realh div 2    
  let translation = (cy+((sur.origin.y0))-y)*sur.realw + cx-(sur.origin.x0)+x
  # echo  cx-(sur.origin.x0 div 2)+x, " ||| ",cy+((sur.origin.y0) div 2)-y
  sur.pixels[translation] = color

proc fillWith*(sur: var Surface,color:Color=White) =
  ## Loop over every pixel in `img` and sets its color to `color` 
  for pix in sur.pixels.mitems: pix = color 

proc saveSurfaceTo*(sur:Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  var tmp = npng.initPNG(sur.realw,sur.realh,sur.pixels)
  tmp.writeToFile(filename)
  

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

  srf[xi,yi] = color
  
  if dx>=dy:
    var err = dy-(dx shr 1)
    while xi != x2:
      if (err >= 0):
        err -= dx
        yi+=iy
      
      err += dy
      xi += ix
      srf[xi,yi] = color
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
  let dx = abs(maxx)+abs(minx)
  let dy = abs(maxy)+abs(miny)
  let xl = if dx mod 2 == 0 : dx+5 else: dx+4 # pad the surface a bit
  let yl = if dy mod 2 == 0 : dy+5 else: dy+4 

  result.pixels = newSeq[Color]((xl.ceil.int) * (yl.ceil.int))
  #result.img = PNG(w: xl.ceil.int, h: yl.ceil.int, pixels: data)
  #TODO: pad width or inner width
  result.realw = xl.ceil.int
  result.realh = yl.ceil.int

  result.width = dx.int
  result.height = dy.int
  
  #echo len(result.pixels)
  #echo result.realw, " ", result.realh

  result.origin = ( (abs(maxx)-abs(minx)).ceil.int div 2, (abs(maxy)-abs(miny)).ceil.int div 2 )

  result.xaxis = (minx.floor.int, maxx.ceil.int)
  result.yaxis = (miny.floor.int, maxy.ceil.int)

proc drawAxis*(sur: var Surface, step:int=1,color:Color=Black) =
  sur.drawLine(sur.xaxis.min,0,sur.xaxis.max,0,color)
  sur.drawLine(0,sur.yaxis.min,0,sur.yaxis.max,color)
  for x in countup(sur.xaxis.min,sur.xaxis.max,step):
    if x != sur.xaxis.min and x != sur.xaxis.max : sur.drawLine(x,-1,x,1,color)
  for y in countup(sur.yaxis.min,sur.yaxis.max,step):
    if y != sur.yaxis.min and y != sur.yaxis.max : sur.drawLine(-1,y,1,y,color)


proc drawFunc*(sur:var Surface, x,y:openarray[float], lncolor:Color=Black, mode:PlotMode=Lines, scale:float=1, yscale:float=1 ) =
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

template plot*(x,y:openarray[float], lncolor:Color=Red, mode:PlotMode=Lines, scale:float=1,yscale:float=1, bgColor:Color = White) =
  let srf = drawXY(x,y,lncolor, mode, scale,yscale, bgColor)
  let pathto = currentSourcePath().changeFileExt(".png")
  #echo pathto
  srf.saveSurfaceTo(pathto)
    

when isMainModule:
  plot([0.0,1,2,3],[0.0,1,2,3])


#[when isMainModule:
  var rt = initSurface( 0,10,0,10 )

  rt.fillWith(Yellow)
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  rt.drawLine(0,0,5,5,Red)
  rt.saveSurfaceTo("test.png")]#