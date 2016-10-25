
import sequtils,math
from algorithm import fill

type 
  Color* = uint32
  Axis* = object
    max*: tuple[val:float,pixel:int]
    min*: tuple[val:float,pixel:int]
    #origin: tuple[val,pixel:int]

  Surface* = object
    width*: int
    height*: int
    x*: Axis
    y*: Axis
    #origin: tuple[x0,y0:int]
    pixels: seq[Color]
    #pixelsize: int
    
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
  
proc pixelFromVal*(a:Axis,val:float):int =
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

proc `[]`*(sur:Surface, i,j:int):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## IN PIXEL
  result = sur.pixels[i*(sur.width)+j]

proc `[]=`*(sur: var Surface, i,j:int, color:Color) =  
  sur.pixels[i*(sur.width)+j] = color

proc `[]`*(sur:Surface, x,y:float):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## VALUES NOT IN PIXEL
  result = sur[sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)]

proc `[]=`*(sur: var Surface, x,y:float, color:Color) =
  echo sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)
  sur[sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)] = color

proc fillWith*(sur: var Surface,color:Color=White) =
  ## Loop over every pixel in `img` and sets its color to `color`
  sur.pixels.fill(color) 
  #for pix in sur.pixels.mitems: pix = color 

proc initAxis*(v0,v1:float,p0=0,p1:int=0): Axis =
  result.max = (v1,p1)
  result.min = (v0,p0)

proc initSurface*(x,y:Axis) : Surface =
  result.x = x
  result.y = y
  result.width = abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = abs(y.max.pixel-y.min.pixel)+1
  result.pixels = newSeq[Color](result.height*result.width)
  result.fillWith(White)  
  #echo result.pixels.len
proc initSurface*(x,y:Axis,w,h:int) : Surface =
  result.x = x
  result.y = y
  result.width = w#abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = h#abs(y.max.pixel-y.min.pixel)+1
  result.x.max.pixel = w-1
  result.y.min.pixel = h-1
  result.pixels = newSeq[Color](result.height*result.width)
  result.fillWith(White) 

when isMainModule:
  import npng,draw

  
  proc saveSurfaceTo*(sur:Surface,filename:string) =
    ## Convience function. Saves `img` into `filename`
    var tmp = npng.initPNG(sur.width,sur.height,sur.pixels)
    tmp.writeToFile(filename)
  
  var x,y : Axis

  x = initAxis(0.0,100.0)
  y = initAxis(0.0,100.0)
  var rt = initSurface( x,y,320,240 )

  rt.line(0.0,0.0,50.0,50.0)
  rt.line(50.0,50.0,100.0,0.0)
  
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  #rt.drawLine(0,0,5,5,Red)
  rt.saveSurfaceTo("tplot.png")
