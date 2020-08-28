import ./surface, nimsvg, strutils, ./color

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
    echo "n"
    result.add sur.xticks(color=color)
    result.add sur.yticks(color=color)

proc gridX(sur: Surface, every: float = 0.10, color:Color=Viridis.gray, ticks:bool=false): string =
  ## Plot a grid with `Color`, the distance between lines is `every` as a percentage.
  let incr =  (sur.x.unpadded.max-sur.x.unpadded.min)*every
  var point = sur.x.unpadded.min
  let ticksize = if not ticks: 0.0 else:(sur.y.max.val-sur.y.min.val)*every/15
  result = ""
  while point <= sur.x.max.val:
    result.add( "M " & $sur.x.pixelFromVal2(point) & " " & $sur.y.pixelFromVal2((sur.y.min.val-ticksize), true) & " L " & $sur.x.pixelFromVal2(point) & " " & $sur.y.pixelFromVal2(sur.y.max.val, true) & " ")
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

proc svg*(s: Surface):string =
  let paths = s.renderLinePlots
  let grid = if s.drawgrid: s.renderGrid else: @[]
  let box = s.renderBox(ticks=true)
  let svgnodes = buildSvg:
    svg(width=s.width, height=s.height, fill= "#" & s.bg.toHex):
      for b in box:
        path(d=b, stroke="black", fill="transparent")
      for i, g in grid:
        path(d=g, stroke="#" & Viridis.gray.toHex, fill="transparent")
      for i, p in paths:
        path(d=p, stroke="#" & s.plots[i].c.toHex, fill="transparent", `stroke-width` = "1.5")
  result = svgnodes.render

proc saveToSvg*(s:Surface, f:string) =
  writeFile(f, s.svg)