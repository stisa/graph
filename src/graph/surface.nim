import ./color

type 
  Axis* = object
    max*: tuple[val:float,pixel:int]
    min*: tuple[val:float,pixel:int]
    origin: float#tuple[val,pixel:int]
    padding: int # % of padding

  Surface* = object
    width*: int
    height*: int
    x*: Axis
    y*: Axis
    ratio: float
    origin*: tuple[x0,y0:float]
    pixels*: seq[Color]
    #pixelsize: int

proc pixelFromVal*(a:Axis,val:float):int =
  let 
    paddedmax = a.max.pixel - (((a.max.pixel-a.min.pixel) * a.padding) div 100).int
    paddedmin = a.min.pixel + (((a.max.pixel-a.min.pixel) * a.padding) div 200).int
  #result = ((( (val) - a.min.val)/(a.max.val-a.min.val) * (a.max.pixel-a.min.pixel).float)+(a.min.pixel).float).int 
  result = (
    (
      ((val) - a.min.val)/(a.max.val-a.min.val) * 
      paddedmax.float
    ) + paddedmin.float
  ).int 


proc `[]`*(sur:Surface, i,j:int):Color =
  ## j: position along the horizontal axis
  ## i: position along the vertical axis
  ## IN PIXEL
  if i >= sur.height or i < 0: return
  if j >= sur.width or j < 0: return
  result = sur.pixels[(sur.height-1-i)*(sur.width)+j]

proc `[]=`*(sur: var Surface, i,j:int, color:Color) =  
  if i >= sur.height or i < 0: return
  if j >= sur.width or j < 0: return
  sur.pixels[(sur.height-1-i)*(sur.width)+j] = color

proc `[]`*(sur:Surface, x,y:float):Color =
  ## x: position along the horizontal axis
  ## y: position along the vertical axis
  ## VALUES NOT IN PIXEL
  result = sur[sur.x.pixelFromVal(x),sur.y.pixelFromVal(y)]

proc `[]=`*(sur: var Surface, x,y:float, color:Color) =
  #echo sur.y.pixelFromVal(y),sur.x.pixelFromVal(x)
  sur[sur.x.pixelFromVal(x), sur.y.pixelFromVal(y)] = color

proc fillWith*(sur: var Surface,color:Color=White) =
  ## Loop over every pixel in `img` and sets its color to `color`
  #sur.pixels.fill(color) 
  for pix in sur.pixels.mitems: pix = Color(color)

proc initAxis*(v0,v1:float,origin:float=0.0,p0=0,p1:int=480, padding=10): Axis =
  ## padding is a percentage?
  result.max = (v1,p1)
  result.min = (v0,p0)
  result.padding = padding
  result.origin = origin

proc initSurface*(x,y:Axis) : Surface =
  result.x = x
  result.y = y
  result.width = abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = abs(y.max.pixel-y.min.pixel)+1
  result.pixels = newSeq[Color](result.height*result.width)
  result.origin = (x.origin,y.origin)
  result.fillWith(White)

proc initSurface*(x0,w,y0,h:int) : Surface =
  result.x = initAxis(x0.float,w.float, 0, 0, w)
  result.y = initAxis(y0.float,h.float, 0, 0, h)
  result.width = w#abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = h#abs(y.max.pixel-y.min.pixel)+1
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
