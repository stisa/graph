type
  Color* = uint32
  
const
  ## Common colors used for testing
  Transparent* = Color(0x00000000)
  Black* = Color(0x000000FF)
  Blue* = Color(0x0000FFFF)
  Green* = Color(0x00FF00FF)
  Red* = Color(0xFF0000FF)
  Purple* = Color(0xFF00FFFF)
  Yellow* = Color(0xFFFF00FF)
  White* = Color(0xFFFFFFFF)
  HalfTBlack* = Color(0x00000088) ## HalfT<Color> colors are <color> at half alpha
  HalfTBlue* = Color(0x0000FF88)
  HalfTGreen* = Color(0x00FF0088)
  HalfTRed* = Color(0xFF000088)
  HalftWhite* = Color(0xFFFFFF88)

proc color ( r,g,b,a:int=0) :Color=
  result = (r shl 24+g shl 16+b shl 8+a).uint32

when isMainModule:
  assert(color(255,000,000,255) == Red)
  