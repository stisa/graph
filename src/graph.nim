import strutils
import 
  ./graph/surface, ./graph/plot, ./graph/color

export color, plot, surface

import ./graph/backendpng, ./graph/backendsvg

export backendpng, backendsvg

proc saveTo*(sur: var Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  if filename.endsWith("svg"):
    sur.saveToSvg(filename)
  elif filename.endsWith("png"):
    sur.saveToPng(filename)
  else:
    raise newException(ValueError, "Only svg and png outputs are supported")

proc saveTo*(sur:Surface,filename:string) =
  ## Convience function. Saves `img` into `filename`
  if filename.endsWith("svg"):
    sur.saveToSvg(filename)
  else:
    raise newException(ValueError, "Only svg and png outputs are supported")

when isMainModule:
  runnableExamples:
    import math, arraymancer
    let x = arange(0.0,10,0.1)
    let y = sin(x)
    let y2 = cos(x)
    var rt = plot(x.data,y.data)
    rt.plot(x.data,y2.data, col=Viridis.orange)
    rt.drawgrid = true
    rt.saveTo("tdraw.png")
    rt.saveTo("tdraw.svg")