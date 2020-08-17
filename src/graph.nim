import nimPNG
import math, base64, streams
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


proc flipX*(srf:var Surface) =
# TODO: swap
  for c in 0..srf.width-1:
    for r in 0..floor((srf.height-1)/2).int :
      #swap(srf[c,r],srf[r,c]) error?
      let tmp = srf[r,c]
      srf[r,c] = srf[srf.height-r-1,c]
      srf[srf.height-r-1,c] = tmp

when isMainModule:
  import graph/color,graph/draw
  var rt = initSurface( 0,160,0,120 )

  rt.fillWith(Yellow)
  ## Plot x,y with color `lncolor` and `scale`
  # TODO: have a switch to use antialiased lines
  #rt.line(0,0,5,5,Red)
  rt.saveTo("test.png")
  echo rt.jupyterPlotData