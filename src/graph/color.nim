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

type Viridis* {.pure.} = enum
  transp = Color(0x00000000)
  blue = Color(0x1f77b4ff)
  green = Color(0x2ca02cff)
  gray = Color(0xbfbfbfff)
  red = Color(0xd62728ff)
  orange = Color(0xff7f0eff)

converter toColor*(v: Viridis): Color {.inline.} = Color(v)

proc color* (r,g,b,a:int=0) :Color=
  assert(abs(r)<256, $r)
  assert(abs(g)<256, $g)
  assert(abs(b)<256, $b)
  assert(abs(a)<256, $a)
  result = (r shl 24+g shl 16+b shl 8+a).uint32
  
proc withAlpha* (c:Color, a:int=0): Color=
  assert(abs(a)<256, $a)
  # -cast[uint8](c).uint32 <- this part reset alpha to 0
  result = (c-cast[uint8](c).uint32+a.uint32).uint32

proc alpha(c: Color): uint32 {.inline.} = cast[uint8](c)

proc blend*( orig: var Color, newc: Color) =
    let 
      alpha = newc.alpha
      inv_alpha = 255 - newc.alpha
    orig = (
      ((alpha * cast[uint8](newc shr 24) + inv_alpha * cast[uint8](orig shr 24)) shr 8) shl 24 +
      ((alpha * cast[uint8](newc shr 16) + inv_alpha * cast[uint8](orig shr 16)) shr 8) shl 16 +
      ((alpha * cast[uint8](newc shr 8) + inv_alpha * cast[uint8](orig shr 8)) shr 8)   shl 8  +
      0xff).uint32

proc blend*( orig: Color, newc: Color): Color =
    let 
      alpha = newc.alpha
      inv_alpha = 255 - newc.alpha
    result = (
      ((alpha * cast[uint8](newc shr 24) + inv_alpha * cast[uint8](orig shr 24)) shr 8) shl 24 +
      ((alpha * cast[uint8](newc shr 16) + inv_alpha * cast[uint8](orig shr 16)) shr 8) shl 16 +
      ((alpha * cast[uint8](newc shr 8) + inv_alpha * cast[uint8](orig shr 8)) shr 8)   shl 8  +
      0xff).uint32


proc `$`*(c:Color):string =
  result = ""
  result.setLen(4)

  result[0] = cast[uint8](c shr 24).char
  result[1] = cast[uint8](c shr 16).char
  result[2] = cast[uint8](c shr 8).char
  result[3] = cast[uint8](c shr 0).char
  
when isMainModule:
  echo repr color(255,000,000,255)
  echo repr color(255,000,000,0)
  echo repr Red
  echo repr Red.withAlpha(0)
  echo repr Red.withAlpha(88)
  echo repr cast[uint8](HalfTGreen) 
