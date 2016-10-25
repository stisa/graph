import plot

proc bresline*(srf:var Surface, x1,y1,x2,y2:int, color : Color = Red) =
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

proc line*(srf:var Surface, x1,y1,x2,y2:float, color : Color = Red) {.inline.} =
  srf.bresline(srf.x.pixelFromVal(x1),srf.y.pixelFromVal(y1),srf.x.pixelFromVal(x2),srf.y.pixelFromVal(y2), color)

proc drawAxis*(sur: var Surface, step:float=1.0,color:Color=Black) =
  sur.line(sur.x.min.val,sur.origin.y0,sur.x.max.val,sur.origin.y0,color)
  sur.line(sur.origin.x0,sur.y.min.val,sur.origin.x0,sur.y.max.val,color)

  # TODO: draw tick
  #for x in countup(sur.xaxis.min,sur.xaxis.max,step):
  #  if x != sur.xaxis.min and x != sur.xaxis.max : sur.drawLine(x,-1,x,1,color)
  #for y in countup(sur.yaxis.min,sur.yaxis.max,step):
  #  if y != sur.yaxis.min and y != sur.yaxis.max : sur.drawLine(-1,y,1,y,color)

when isMainModule:
  import npng

  
  proc saveSurfaceTo*(sur:Surface,filename:string) =
    ## Convience function. Saves `img` into `filename`
    var tmp = npng.initPNG(sur.width,sur.height,sur.pixels)
    tmp.writeToFile(filename)
  
  var x,y : Axis

  x = initAxis(-10.0,100.0)
  y = initAxis(-10.0,100.0)
  var rt = initSurface( x,y,320,240 )

  rt.line(0.0,0.0,50.0,50.0)
  rt.line(50.0,50.0,100.0,0.0)
  rt.drawAxis()
  
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  #rt.drawLine(0,0,5,5,Red)
  rt.saveSurfaceTo("tplot.png")
