# Package

version       = "0.4.0"
author        = "stisa"
description   = "Beginning of a 2D plotting library for Nim"
license       = "MIT"

srcDir = "src"

# Dependencies
requires "nimPNG"
requires "nimsvg"
requires "nim >= 0.15.2"

task examples, "Build examples":
  withDir "examples":
    exec("nim c -r example1.nim")
    exec("nim c -r example2.nim")
    #exec("nim c -r example3.nim")

task current, "Build current.png":
  withDir "notes":
    exec("nim c -r current.nim")

task docs, "Build docs":
  exec(r"nim doc --docRoot:@pkg --project --outdir:docs .\src\graph.nim")