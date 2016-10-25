import npng
import sequtils,math

type 
  Color* = uint32
  Axis* = object
    max: tuple[val:float,pixel:int]
    min: tuple[val:float,pixel:int]
    origin: tuple[val,pixel:int]

  Surface* = object
    width: int
    height: int
    x: Axis
    y: Axis
    origin: tuple[x0,y0:int]
    pixels: seq[Color]
    pixelsize: int
    
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
  
proc pixelFromVal(a:Axis,val:float):int =
  when defined debug:
    echo "start pp"
    echo "val",val
    echo (val - a.min.val)
    echo (a.max.val-a.min.val)
    echo (a.max.pixel-a.min.pixel)
    echo a.min.pixel
    echo (((val - a.min.val)/(a.max.val-a.min.val) * (a.max.pixel-a.min.pixel).float)+(a.min.pixel).float)
    echo "end pp"
  result = (((val - a.min.val)/(a.max.val-a.min.val) * (a.max.pixel-a.min.pixel).float)+(a.min.pixel).float).int 

proc `[]`(sur:Surface, i,j:int):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## IN PIXEL
  result = sur.pixels[i*(sur.width)+j]

proc `[]=`(sur: var Surface, i,j:int, color:Color) =  
  sur.pixels[i*(sur.width)+j] = color

proc `[]`(sur:Surface, x,y:float):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## VALUES NOT IN PIXEL
  result = sur[sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)]

proc `[]=`(sur: var Surface, x,y:float, color:Color) =
  echo sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)
  sur[sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)] = color

proc fillWith*(sur: var Surface,color:Color=White) =
  ## Loop over every pixel in `img` and sets its color to `color` 
  for pix in sur.pixels.mitems: pix = color 

proc initAxis(v0,v1:float,p0,p1:int): Axis =
  result.max = (v1,p1)
  result.min = (v0,p0)

proc initSurface(x,y:Axis) : Surface =
  result.x = x
  result.y = y
  result.width = abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = abs(y.max.pixel-y.min.pixel)+1
  result.pixels = newSeq[Color](result.height*result.width)  
  #echo result.pixels.len

proc saveSurfaceTo*(sur:Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  var tmp = npng.initPNG(sur.width,sur.height,sur.pixels)
  tmp.writeToFile(filename)

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

proc drawLine*(srf:var Surface, x1,y1,x2,y2:float, color : Color = Black) {.inline.} =
  srf.drawLine(srf.x.pixelFromVal(x1),srf.y.pixelFromVal(y1),srf.x.pixelFromVal(x2),srf.y.pixelFromVal(y2), color)

when isMainModule:
  var x,y : Axis

  x = initAxis(0.0,10.0,0,99)
  y = initAxis(0.0,10.0,99,0)
  var rt = initSurface( x,y )

  rt.fillWith(Yellow)
  rt[0.0,0.0] = Black
  rt[5.0,5.0] = Red
  
  rt.drawLine(0.0,0.0,5.0,5.0)
  
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  #rt.drawLine(0,0,5,5,Red)
  rt.saveSurfaceTo("tplot.png")
