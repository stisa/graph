import ./surface, nimPNG, ./color

import math

proc aaline(srf:var Surface, x0,y0,x1,y1:int, w: float = 1.0, color : Color = Red) =
  # Anti aliased thick line with a modified bresenham line algorithm
  # see http://members.chello.at/easyfilter/bresenham.html
  var 
    dx = abs(x1-x0)
    dy = abs(y1-y0)
    sx = if x0<x1: 1 else: -1
    sy = if y0<y1: 1 else: -1
    err = dx-dy  
    ed = if dx+dy == 0: 1.0 else: sqrt((dx * dx + dy * dy).float)
    e2, x2, y2: int
  
  var 
    hfw = 0.5*(1+w) # half the width
    xi = x0
    yi = y0
  while true:
    var ap = 255-(255*(abs(err-dx+dy).float / ed - hfw + 1)).int
    #echo "first ", ap
    srf[yi,xi] = srf[yi,xi].blend(color.withAlpha(min(max(0, ap),255)))
    e2 = err
    x2 = xi
    if(2*e2 >= -dx):
      e2 += dy
      y2 = yi
      while e2.float < ed*w and (y1 != y2 or dx > dy):
        y2 += sy
        ap = 255-(255*(abs(e2).float/ed - hfw + 1)).int
        #echo "second ", ap
        srf[y2,xi] = srf[y2,xi].blend(color.withAlpha(min(max(0, ap),255)))
        e2 += dx
      
      if(xi==x1): break
      e2 = err
      err -= dy
      xi += sx
    
    if(2*e2 <= dy):
      e2 = dx-e2
      while e2.float < ed*w and (x1 != x2 or dx < dy):
        x2 += sx
        ap = 255-(255*(abs(e2).float/ed - hfw + 1)).int
        #echo "third ", ap
        srf[yi,x2] = srf[yi,x2].blend(color.withAlpha(min(max(0, ap),255)))
        e2 += dy
    
      if(yi==y1): break
      err += dx
      yi += sy

proc renderLine(srf:var Surface, x1,y1,x2,y2:float, w:float=1.0, color : Color = Red) {.inline.} =
  srf.aaline(srf.x.pixelFromVal(srf.origin.x0+x1), srf.y.pixelFromVal(srf.origin.y0+y1),
              srf.x.pixelFromVal(srf.origin.x0+x2),srf.y.pixelFromVal(srf.origin.y0+y2), w, color)

proc xticks(sur: var Surface, every: float = 0.20, color:Color=Viridis.gray) =
  ## Plot ticks with `Color`, the distance between ticks is `every` as a percentage.
  let incr =  (sur.x.unpadded.max-sur.x.unpadded.min)*every
  var point = sur.x.unpadded.min
  let ticksize = (sur.y.max.val-sur.y.min.val)*every/15
  while point <= sur.x.max.val:
    sur.renderLine(point, sur.y.min.val-ticksize , point, sur.y.min.val, 1.0, color)
    point += incr

proc yticks(sur: var Surface, every: float = 0.10, color:Color=Viridis.gray) =
  ## Plot ticks with `Color`, the distance between ticks is `every` as a percentage.
  let incr =  (sur.y.unpadded.max-sur.y.unpadded.min)*every
  var point = sur.y.unpadded.min
  let ticksize = (sur.x.max.val-sur.x.min.val)*every/10
  while point <= sur.y.max.val:
    sur.renderLine(sur.x.min.val-ticksize, point, sur.x.min.val, point, 1.0, color)
    point += incr


proc renderBox(sur: var Surface, color:Color=Black, ticks: bool = false) =
  ## Plot a box around the drawable part of the plot
  ## ## If `ticks` is true, ticks are also plotted
  sur.renderLine(sur.x.min.val, sur.y.min.val , sur.x.min.val, sur.y.max.val, 1.0, color)
  sur.renderLine(sur.x.min.val, sur.y.min.val , sur.x.max.val, sur.y.min.val, 1.0, color)
  sur.renderLine(sur.x.max.val, sur.y.min.val , sur.x.max.val, sur.y.max.val, 1.0, color)
  sur.renderLine(sur.x.min.val, sur.y.max.val , sur.x.max.val, sur.y.max.val, 1.0, color)
  if ticks:
    sur.xticks(color=color)
    sur.yticks(color=color)

proc gridX(sur: var Surface, every: float = 0.10, color:Color=Viridis.gray, ticks:bool=false) =
  ## Plot a grid with `Color`, the distance between lines is `every` as a percentage.
  let incr =  (sur.x.unpadded.max-sur.x.unpadded.min)*every
  var point = sur.x.unpadded.min
  let ticksize = if not ticks: 0.0 else:(sur.y.max.val-sur.y.min.val)*every/15
  while point <= sur.x.max.val:
    sur.renderLine(point, sur.y.min.val-ticksize , point, sur.y.max.val, 1.0, color)
    point += incr

proc gridY(sur: var Surface, every: float = 0.10, color:Color=Viridis.gray, ticks:bool=false) =
  ## Plot a grid with `Color`, the distance between lines is `every` as a percentage.
  let incr =  (sur.y.unpadded.max-sur.y.unpadded.min)*every
  var point = sur.y.unpadded.min
  let ticksize = if not ticks: 0.0 else: (sur.x.max.val-sur.x.min.val)*every/10
  while point <= sur.y.max.val:
    sur.renderLine(sur.x.min.val-ticksize, point, sur.x.max.val, point, 1.0, color)
    point += incr

proc renderGrid(sur: var Surface, everyX: float = 0.2, everyY: float = 0.10, color:Color=Viridis.gray, ticks:bool=false) =
  ## Plot a grid with `Color`, the distance between lines is `every` as a percentage.
  ## If `ticks` is true, the lines extend slightly outside
  sur.gridX(everyX, color, ticks)
  sur.gridY(everyY, color, ticks)


proc render(srf: var Surface) =
  srf.fillWith(srf.bg)
  
  if srf.drawgrid: 
    srf.renderGrid
  if srf.drawbox:
    srf.renderBox(ticks=srf.drawticks)

  # color up the lines, FIFO
  for plot in srf.plots.mitems:
    # if done, we don't need to redraw
    if plot.done: continue
    for i in 0..<plot.x.len-1: 
      srf.renderLine(plot.x[i],plot.y[i], plot.x[i+1], plot.y[i+1], 1.5, plot.c)
    plot.done = true

proc saveToPng*(sur: var Surface, filename:string) =
  ## Convience function. Saves `img` into `filename`
  sur.render
  var px = ""
  for p in sur.pixels: px.add($p)
  if not savepng32(filename,px,sur.width,sur.height): 
    assert(false,"Error saving")

proc png*(sur: var Surface): PNG[string] =
  sur.render
  var px = ""
  for p in sur.pixels: px.add($p)
  result = encodePNG32(px,sur.width,sur.height)