# Package

version       = "0.1.0"
author        = "Stisa"
description   = "Toy plotting library for Nim"
license       = "MIT"


# Dependencies

requires "nim >= 0.14.0"

task buildexamples, "Build examples":
  withDir "examples":
    exec("nim c -r example1.nim")
    exec("nim c -r example2.nim")
    #exec("nim c -r example3.nim")