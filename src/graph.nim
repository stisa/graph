import nimPNG
import base64, streams
import 
  ./graph/surface, ./graph/draw, ./graph/color

export color, draw, surface

proc saveTo*(sur:Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  var px = ""
  for p in sur.pixels: px.add($p)
  if not savepng32(filename,px,sur.width,sur.height): assert(false,"Error saving")

proc png*(sur:Surface): PNG[string] =
  var px = ""
  for p in sur.pixels: px.add($p)
  result = encodePNG32(px,sur.width,sur.height)

proc jupyterPlotData*(sur:Surface): string {.deprecated.}=
  ## Returns the plot in the base64-"#>jnps0000x0000"/"jnps<#" delimited
  ## format jupyternim expects
  var px = ""
  for p in sur.pixels: px.add($p)
  var ss = newStringStream("")
  writeChunks(encodePNG32(px,sur.width,sur.height), ss)
  ss.setPosition(0)

  var sw = $sur.width
  var sh = $sur.height
  #FIXME: assumes w/h are either 3 or 4 digits
  if sw.len!=4: sw = "0" & sw
  if sh.len!=4: sh = "0" & sh

  result = "#>jnps" & sw & "x" & sh & ss.readAll.encode() & "jnps<#"

# New api idea ###
import graph/backendpng, graph/backendsvg
export backendpng, backendsvg
##########

when isMainModule:
  import nimsvg, math, arraymancer
  let x = arange(0.0,10,0.1)
  let y = sin(x)
  var rt = xy(x.data,y.data)
  rt.drawgrid = true
  rt.saveToPng("tdraw.png")
  rt.saveToSvg("tdraw.svg")