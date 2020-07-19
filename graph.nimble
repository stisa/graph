# Package

version       = "0.3.0"
author        = "stisa"
description   = "Beginning of a 2D plotting library for Nim"
license       = "MIT"

srcDir = "src"

# Dependencies
requires "nimPNG"
requires "nim >= 0.15.2"

task buildexamples, "Build examples":
  withDir "examples":
    exec("nim c -r example1.nim")
    exec("nim c -r example2.nim")
