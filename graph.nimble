# Package

version       = "0.2.0"
author        = "Stisa"
description   = "Toy plotting library for Nim"
license       = "MIT"


# Dependencies
requires "nimPNG"
requires "nim >= 0.15.2"

task buildexamples, "Build examples":
  withDir "examples":
    exec("nim c -r example1.nim")
    exec("nim c -r example2.nim")
