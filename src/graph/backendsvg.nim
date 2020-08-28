import ./surface, nimsvg, ./color, strformat

proc renderLinePlots(s:Surface): seq[string] =
  # return a seq[string] containing the svg paths
  # defined by s.plots 
  result.setLen(s.plots.len)
  for i, path in result.mpairs:
    for j in 0..<len(s.plots[i].x):
      if j == 0:
        path.add("M " & $s.x.pixelFromVal2(s.plots[i].x[j]) & 
                  " " & $s.y.pixelFromVal2(s.plots[i].y[j], true))
        continue
      path.add(" L " & $s.x.pixelFromVal2(s.plots[i].x[j]) & 
                  " " & $s.y.pixelFromVal2(s.plots[i].y[j], true))

proc xticks(sur: Surface, every: float = 0.20, color:Color=Viridis.gray):string =
  ## Plot ticks with `Color`, the distance between ticks is `every` as a percentage.
  let incr =  (sur.x.unpadded.max-sur.x.unpadded.min)*every
  var point = sur.x.unpadded.min
  let ticksize = (sur.y.max.val-sur.y.min.val)*every/15
  result = ""
  while point <= sur.x.max.val:
    result.add( "M " & $sur.x.pixelFromVal2(point) & " " & $sur.y.pixelFromVal2((sur.y.min.val-ticksize), true) & " L " & $sur.x.pixelFromVal2(point) & " " & $sur.y.pixelFromVal2(sur.y.min.val, true) & " ")
    point += incr

proc yticks(sur: Surface, every: float = 0.10, color:Color=Viridis.gray):string =
  ## Plot ticks with `Color`, the distance between ticks is `every` as a percentage.
  let incr =  (sur.y.unpadded.max-sur.y.unpadded.min)*every
  var point = sur.y.unpadded.min
  let ticksize = (sur.x.max.val-sur.x.min.val)*every/10
  result = ""
  while point <= sur.y.max.val:
    result.add( "M " & $sur.x.pixelFromVal2(sur.x.min.val-ticksize) & " " & $sur.y.pixelFromVal2(point, true) & " L " & $sur.x.pixelFromVal2(sur.x.min.val) & " " & $sur.y.pixelFromVal2(point, true) & " ")
    point += incr
  
proc renderBox(sur: Surface, color:Color=Black, ticks: bool = false): seq[string] =
  ## Plot a box around the drawable part of the plot
  ## ## If `ticks` is true, ticks are also plotted
  result.add "M " & $sur.x.pixelFromVal2(sur.x.min.val) & " " & $sur.y.pixelFromVal2(sur.y.min.val, true) & " L " &  $sur.x.pixelFromVal2(sur.x.min.val) & " " &  $sur.y.pixelFromVal2(sur.y.max.val, true) & 
    " L " &  $sur.x.pixelFromVal2(sur.x.max.val) & " " &  $sur.y.pixelFromVal2(sur.y.max.val, true) & " L " &  $sur.x.pixelFromVal2(sur.x.max.val) & " " &  $sur.y.pixelFromVal2(sur.y.min.val, true) & 
    " L " & $sur.x.pixelFromVal2(sur.x.min.val) & " " & $sur.y.pixelFromVal2(sur.y.min.val, true)
  if ticks:
    result.add sur.xticks(color=color)
    result.add sur.yticks(color=color)

proc gridX(sur: Surface, every: float = 0.10, color:Color=Viridis.gray, ticks:bool=false): string =
  ## Plot a grid with `Color`, the distance between lines is `every` as a percentage.
  let incr =  (sur.x.unpadded.max-sur.x.unpadded.min)*every
  var point = sur.x.unpadded.min
  let ticksize = if not ticks: 0.0 else:(sur.y.max.val-sur.y.min.val)*every/15
  result = ""
  while point <= sur.x.max.val:
    result.add( fmt"M {sur.x.pixelFromVal2(point):.4f} {sur.y.pixelFromVal2((sur.y.min.val-ticksize), true):.4f} L {sur.x.pixelFromVal2(point):.4f} {sur.y.pixelFromVal2(sur.y.max.val, true):.4f} ")
    point += incr

proc gridY(sur: Surface, every: float = 0.10, color:Color=Viridis.gray, ticks:bool=false): string=
  ## Plot a grid with `Color`, the distance between lines is `every` as a percentage.
  let incr =  (sur.y.unpadded.max-sur.y.unpadded.min)*every
  var point = sur.y.unpadded.min
  let ticksize = if not ticks: 0.0 else: (sur.x.max.val-sur.x.min.val)*every/10
  result = ""
  while point <= sur.y.max.val:
    result.add( "M " & $sur.x.pixelFromVal2(sur.x.min.val-ticksize) & " " & $sur.y.pixelFromVal2(point, true) & " L " & $sur.x.pixelFromVal2(sur.x.max.val) & " " & $sur.y.pixelFromVal2(point, true) & " ")
    point += incr
  
proc renderGrid(sur: Surface, everyX: float = 0.2, everyY: float = 0.10, color:Color=Viridis.gray, ticks:bool=false) : seq[string] =
  ## Plot a grid with `Color`, the distance between lines is `every` as a percentage.
  ## If `ticks` is true, the lines extend slightly outside
  result = @[sur.gridX(everyX, color, ticks)]
  result &= sur.gridY(everyY, color, ticks)

proc xlabels(sur: Surface, every: float = 0.20, color:Color=Black):Nodes =
  ## Plot ticks with `Color`, the distance between ticks is `every` as a percentage.
  let incr =  (sur.x.unpadded.max-sur.x.unpadded.min)*every
  var point = sur.x.unpadded.min
  let pt = 1.333
  
  while point <= sur.x.max.val:
    let tmp = buildSvg:
        text( x=sur.x.pixelFromVal2(point)-pt*2, y=sur.y.pixelFromVal2((sur.y.min.val), true)+pt*14, fill = fmt"#{color:08x}", `font-size`= "9pt"):
          t fmt"{point:g}"
    result.add(tmp)
    point += incr

proc ylabels(sur: Surface, every: float = 0.1, color:Color=Black):Nodes =
  ## Plot ticks with `Color`, the distance between ticks is `every` as a percentage.
  let incr =  (sur.y.unpadded.max-sur.y.unpadded.min)*every
  var point = sur.y.unpadded.min
  let pt = 1.333
  while point <= sur.y.max.val:
    let tmp = buildSvg:
      text(x=sur.x.pixelFromVal2(sur.x.min.val)-pt*10*3, y=sur.y.pixelFromVal2(point, true)+pt*3, fill = fmt"#{color:08x}", `font-size`= "9pt"):
        t fmt"{point:+.2g}"
    result.add(tmp)
    point += incr

proc renderLabels(sur:Surface): Nodes =
  result = sur.xlabels
  result.add(sur.ylabels)

proc svg*(s: Surface):string =
  let paths = s.renderLinePlots
  let grid = if s.drawgrid: s.renderGrid else: @[]
  let box = if s.drawbox: s.renderBox(ticks=s.drawticks) else: @[]
  let svgnodes = buildSvg:
    svg(width= fmt"{s.width}", height= fmt"{s.height}", fill= fmt"#{s.bg:08x}"):
      for b in box:
        path(d=b, stroke="black", fill="transparent")
      for i, g in grid:
        path(d=g, stroke= fmt"#{ord(Viridis.gray):08x}", fill="transparent")
      for i, p in paths:
        path(d=p, stroke= fmt"#{s.plots[i].c:08x}", fill="transparent", `stroke-width` = "1.5pt")
      embed s.renderLabels
  result = svgnodes.render

proc saveToSvg*(s:Surface, f:string) =
  writeFile(f, s.svg)