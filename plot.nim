import npng
import sequtils,math

type 
  Color* = uint32
  Axis* = 
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
  let k = (a.max.val - val) / (a - a.min.val)
  result = int((a.max.pixel+a.min.pixe*k)/(k+1)) 

proc `[]`(sur:Surface, x,y:int):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## IN PIXEL
  result = sur.pixels[y*sur.width+x]

proc `[]=`(sur: var Surface, x,y:int, color:Color) =  
  sur.pixels[y*sur.width+x] = color

proc `[]`(sur:Surface, x,y:float):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## NOT IN PIXEL
  result = sur[proportionPixel(x),proportionPixel(y)]

proc `[]=`(sur: var Surface, x,y:float, color:Color) =  
  sur[proportionPixel(x),proportionPixel(y)] = color

proc fillWith*(sur: var Surface,color:Color=White) =
  ## Loop over every pixel in `img` and sets its color to `color` 
  for pix in sur.pixels.mitems: pix = color 

proc saveSurfaceTo*(sur:Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  var tmp = npng.initPNG(sur.width,sur.height,sur.pixels)
  tmp.writeToFile(filename)

when isMainModule:
  var rt = initSurface( 0,10,0,10 )

  rt.fillWith(Yellow)
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  #rt.drawLine(0,0,5,5,Red)
  rt.saveSurfaceTo("tplot.png")