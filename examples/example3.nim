import graph

var srf = initSurface( 0, 320, 0, 240 ) # TODO: dehardcode
srf.fillWith(White)
# note: in the following the parameters are pixels
# the first is the row (eqv to the y pos)
# the second is the col ( eqv to the x pos)
srf.bresline(0,0, 160, 120, Viridis.red)
srf.aaline(0,240, 160, 120, 1.0, Viridis.blue)
srf.saveTo("example3.png")
