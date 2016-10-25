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
  echo i,j," ",sur.width
  echo "comp",i*(sur.width)+j
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
  echo result.pixels.len
proc saveSurfaceTo*(sur:Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  var tmp = npng.initPNG(sur.width,sur.height,sur.pixels)
  tmp.writeToFile(filename)


when isMainModule:
  var x,y : Axis

  x = initAxis(0.0,10.0,0,9)
  y = initAxis(0.0,10.0,9,0)
  var rt = initSurface( x,y )
  echo "x",x
  echo "y",y
  echo "0.0 on x: ",x.pixelFromVal(0.0)
  echo "0.0 on y: ",y.pixelFromVal(0.0)

  echo "5.0 on x: ",x.pixelFromVal(5.0)
  echo "5.0 on y: ",y.pixelFromVal(5.0)
  rt.fillWith(Yellow)
  rt[0.0,0.0] = Black
  rt[5.0,5.0] = Red
  
  
  for i in 0..<rt.width:
  #  echo "f",float(i)
    rt[float(i),i.float*0.5] = Black
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  #rt.drawLine(0,0,5,5,Red)
  rt.saveSurfaceTo("tplot.png")
