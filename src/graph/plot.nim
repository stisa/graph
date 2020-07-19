import ./color
import sequtils,math
#from algorithm import fill

type 
  Axis* = object
    max*: tuple[val:float,pixel:int]
    min*: tuple[val:float,pixel:int]
    origin: float#tuple[val,pixel:int]

  Surface* = object
    width*: int
    height*: int
    x*: Axis
    y*: Axis
    origin*: tuple[x0,y0:float]
    pixels*: seq[Color]
    #pixelsize: int

proc pixelFromVal*(a:Axis,val:float):int =
  result = ((( (val) - a.min.val)/(a.max.val-a.min.val) * (a.max.pixel-a.min.pixel).float)+(a.min.pixel).float).int 

proc `[]`*(sur:Surface, i,j:int):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## IN PIXEL
  if i >= sur.height or i < 0: return
  if j >= sur.width or j < 0: return
  result = sur.pixels[i*(sur.width)+j]

proc `[]=`*(sur: var Surface, i,j:int, color:Color) =  
  if i >= sur.height or i < 0: return
  if j >= sur.width or j < 0: return
  sur.pixels[i*(sur.width)+j] = color

proc `[]`*(sur:Surface, x,y:float):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## VALUES NOT IN PIXEL
  result = sur[sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)]

proc `[]=`*(sur: var Surface, x,y:float, color:Color) =
  #echo sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)
  sur[sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)] = color

proc fillWith*(sur: var Surface,color:Color=White) =
  ## Loop over every pixel in `img` and sets its color to `color`
  #sur.pixels.fill(color) 
  for pix in sur.pixels.mitems: pix = Color(color)

proc initAxis*(v0,v1:float,origin:float=0.0,p0=0,p1:int=0): Axis =
  result.max = (v1,p1)
  result.min = (v0,p0)
  result.origin = origin

proc initSurface*(x,y:Axis) : Surface =
  result.x = x
  result.y = y
  result.width = abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = abs(y.max.pixel-y.min.pixel)+1
  result.pixels = newSeq[Color](result.height*result.width)
  result.origin = (x.origin,y.origin)
  result.fillWith(White)

proc initSurface*(x,y:Axis,w,h:int) : Surface =
  result.x = x
  result.y = y
  result.width = w#abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = h#abs(y.max.pixel-y.min.pixel)+1
  result.x.max.pixel = w-1
  result.y.min.pixel = h-1
  result.pixels = newSeq[Color](result.height*result.width)
  result.origin = (x.origin,y.origin)
  result.fillWith(White) 

proc initSurface*(x0,w,y0,h:int) : Surface =
  result.x = initAxis(x0.float,w.float)
  result.y = initAxis(y0.float,h.float)
  result.width = w#abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = h#abs(y.max.pixel-y.min.pixel)+1
  result.x.max.pixel = w-1
  result.y.min.pixel = h-1
  result.pixels = newSeq[Color](result.height*result.width)
  result.origin = (result.x.origin,result.y.origin)
  result.fillWith(White) 
  
when isMainModule:
  import nimPNG,draw

  
  proc saveTo*(sur:Surface,filename:string) =
    ## Convience function. Saves `img` into `filename`
    var d = ""
    for e in sur.pixels: d.add($e)
    discard savepng32(filename,d,sur.width,sur.height)
  
  var x,y : Axis

  x = initAxis(0.0,100.0)
  y = initAxis(0.0,100.0)
  var rt = initSurface( x,y,320,240 )

  rt.line(0.0,0.0,50.0,50.0)
  rt.line(50.0,50.0,100.0,0.0)
  
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  #rt.drawLine(0,0,5,5,Red)
  rt.saveTo("tplot.png")
