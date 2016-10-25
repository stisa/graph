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
  
proc proportionPixel(a:Axis,val:float):int =
  if val-a.min.val < 0.00001: #precision
    return a.min.pixel
  let k = abs((a.max.val - val) / (val - a.min.val))
  result = int( (a.max.pixel+a.min.pixel).float*k / (k+1) ) 

proc `[]`(sur:Surface, x,y:int):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## IN PIXEL
  result = sur.pixels[(sur.height-1-y)*sur.width+x]

proc `[]=`(sur: var Surface, x,y:int, color:Color) =  

  sur.pixels[(sur.height-1-y)*sur.width+x] = color

proc `[]`(sur:Surface, x,y:float):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## NOT IN PIXEL
  echo sur.x.proportionPixel(x)," ",sur.y.proportionPixel(y)
  result = sur[sur.x.proportionPixel(x),sur.y.proportionPixel(y)]

proc `[]=`(sur: var Surface, x,y:float, color:Color) =
  echo sur.x.proportionPixel(x)," ",sur.y.proportionPixel(y)  
  sur[sur.x.proportionPixel(x),sur.y.proportionPixel(y)] = color

proc fillWith*(sur: var Surface,color:Color=White) =
  ## Loop over every pixel in `img` and sets its color to `color` 
  for pix in sur.pixels.mitems: pix = color 

proc initAxis(v0,v1:float,p0,p1:int): Axis =
  result.max = (v1,p1)
  result.min = (v0,p0)


proc initSurface(x0,x1,y0,y1:float) : Surface =
  result.x = initAxis(x0,x1,0,1)
  result.y = initAxis(y0,y1,0,1)
  result.width = int(ceil(abs(x1-x0))) #wtf
  result.height = int(ceil(abs(y1-y0)))
  result.x.max.pixel = result.width
  result.y.max.pixel = result.height
  result.pixels = newSeq[Color](result.height*result.width)

proc initSurface(x,y:Axis) : Surface =
  result.x = x
  result.y = y
  result.width = int(ceil(abs(x.max.val-x.min.val))) #wtf
  result.height = int(ceil(abs(y.max.val-y.min.val)))
  result.x.max.pixel = result.width
  result.y.max.pixel = result.height
  result.pixels = newSeq[Color](result.height*result.width)
  

proc saveSurfaceTo*(sur:Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  var tmp = npng.initPNG(sur.width,sur.height,sur.pixels)
  tmp.writeToFile(filename)


when isMainModule:
  var rt = initSurface( -10.0,10.0, 0.0,20.0 )

  rt.fillWith(Yellow)
  for i in 0..10:
    rt[float(i),i.float*2] = Black
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  #rt.drawLine(0,0,5,5,Red)
  rt.saveSurfaceTo("tplot.png")