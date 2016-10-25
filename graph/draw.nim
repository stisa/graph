import plot

proc line*(srf:var Surface, x1,y1,x2,y2:int, color : Color = Black) =
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

proc line*(srf:var Surface, x1,y1,x2,y2:float, color : Color = Black) {.inline.} =
  srf.bresline(srf.x.pixelFromVal(x1),srf.y.pixelFromVal(y1),srf.x.pixelFromVal(x2),srf.y.pixelFromVal(y2), color)

