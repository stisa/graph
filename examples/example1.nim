import ../graph

var srf = initSurface(-240,320,-240,240)
srf.fillWith(White)
srf.drawAxis(10)
srf.drawBresLine(0,0,100,100,Red)
srf.drawBresLine(0,0,-100,100,Green)
srf.drawBresLine(0,0,100,-100,Blue)
srf.drawBresLine(0,0,-100,-100,Purple)
srf.drawBresLine(-100,100,100,100,Yellow)
srf.saveSurfaceTo("example1.png")