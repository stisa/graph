let beg ="""<svg version="1.1"
     baseProfile="full"
     width="300" height="200"
     xmlns="http://www.w3.org/2000/svg">
   <polyline
     fill="none"
     stroke="#0074d9"
     stroke-width="3"
     points="
"""
let en = "</svg>"

var pts : seq[float] = @[
       0.0 ,1.50,
       20,60,
       40,80,
       60,20]

proc tuplify(s: seq[float]):string=
  var i = 0
  result = ""
  while i < s.high:
    result.add($s[i]&","& $s[i+1]&" ")
    i = i+2

echo tuplify(pts)
