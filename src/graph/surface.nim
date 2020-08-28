import ./color
import math
type 
  Axis* = object
    max*: tuple[val:float,pixel:int]
    min*: tuple[val:float,pixel:int]
    unpadded*: tuple[min:float, max: float]
    origin: float#tuple[val,pixel:int]
    padding: int # % of padding
    #TODO: idea: tickevery: float # every % make a tick, also defines grids

  Surface* = object
    width*: int
    height*: int
    x*: Axis
    y*: Axis
    ratio: float
    origin*: tuple[x0,y0:float]
    pixels*: seq[Color]
    plots*: seq[tuple[x,y:seq[float],c:Color, done:bool]]
    bg*: Color
    drawgrid*: bool
    drawbox*: bool
    drawticks*: bool
    drawlabels*: bool
    #CHECK: other alternatives:
    #bg: seq[Color] # background pixels (background, grids etc)
    #fg: seq[Color] # foreground pixels (plot lines)
    # and then blend on save?
    #pixelPairs*: seq[tuple[x:int,y:int]] # a seq of pair of pixels values to be connected by a line
    #pixelsize: int

proc pixelFromVal*(a:Axis,val:float):int =
  let 
    paddedmax = a.max.pixel - (((a.max.pixel-a.min.pixel) * a.padding) div 100).int
    paddedmin = a.min.pixel + (((a.max.pixel-a.min.pixel) * a.padding) div 200).int
  #result = ((( (val) - a.min.val)/(a.max.val-a.min.val) * (a.max.pixel-a.min.pixel).float)+(a.min.pixel).float).int 
  result = (
    ( # We lose too much precision converting to int here :/
      (((val) - a.min.val)/(a.max.val-a.min.val)) * 
      paddedmax.float
    ) + paddedmin.float
  ).round.int
proc pixelFromVal2*(a:Axis,val:float, invert:bool=false):float =
  let 
    paddedmax = a.max.pixel - (((a.max.pixel-a.min.pixel) * a.padding) div 100)
    paddedmin = a.min.pixel + (((a.max.pixel-a.min.pixel) * a.padding) div 200)
  #result = ((( (val) - a.min.val)/(a.max.val-a.min.val) * (a.max.pixel-a.min.pixel).float)+(a.min.pixel).float).int 
  if not invert:
    result = (
      (
        ((val) - a.min.val)/(a.max.val-a.min.val) * 
        paddedmax.float
      ) + paddedmin.float
    ) 
  else:
    result = a.max.pixel.float - (
      (
        ((val) - a.min.val)/(a.max.val-a.min.val) * 
        paddedmax.float
      ) + paddedmin.float
    )
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

proc initAxis*(v0,v1:float,origin:float=0.0,p0=0,p1:int=288, padding=10): Axis =
  ## padding is a percentage?
  let padfloat = (v1-v0) * (padding / 200)
  result.max = (v1+padfloat,p1)
  result.min = (v0-padfloat,p0)
  result.padding = padding
  result.origin = origin
  result.unpadded = (v0,v1)

proc initSurface*(x,y:Axis) : Surface =
  result.x = x
  result.y = y
  result.width = abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = abs(y.max.pixel-y.min.pixel)+1
  result.pixels = newSeq[Color](result.height*result.width)
  result.origin = (x.origin,y.origin)
  result.bg = White
  result.plots = @[]

proc initSurface*(x0,w,y0,h:int) : Surface =
  result.x = initAxis(x0.float,w.float, 0, 0, w)
  result.y = initAxis(y0.float,h.float, 0, 0, h)
  result.width = w#abs(x.max.pixel-x.min.pixel)+1 #wtf
  result.height = h#abs(y.max.pixel-y.min.pixel)+1
  result.pixels = newSeq[Color](result.height*result.width)
  result.origin = (result.x.origin,result.y.origin)

proc grid*(s: var Surface) = s.drawgrid = true
proc box*(s: var Surface, ticks=false) = 
  s.drawbox = true
  if ticks:
    s.drawticks = true
    s.drawlabels = true