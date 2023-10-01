# Package

version       = "0.1.0"
author        = "Thiago Navarro"
description   = "Cards Games Strategist"
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["kardy"]
binDir        = "public/script"

backend = "js"

# Dependencies

requires "nim >= 2.0.0"

requires "karax"

requires "util"


from std/strformat import fmt
from std/os import `/`

task finalize, "Uglify and add header":
  let
    f = binDir / bin[0] & "." & backend
    outF = binDir / bin[0] & ".min." & backend
  exec fmt"uglifyjs -o {outF} {f}"
  rmFile f

task buildRelease, "Build release version":
  exec "nimble -d:danger build"

after build:
  finalizeTask()
