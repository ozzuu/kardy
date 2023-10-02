# Package

version       = "0.2.0"
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

const styleDir = "public/style"

task finalize, "Uglify and add header":
  let
    f = binDir / bin[0] & "." & backend
    outF = binDir / bin[0] & ".min." & backend
  exec findExe("uglifyjs") & fmt" -o {outF} {f}"
  rmFile f

task buildCss, "Builds Sass and add it to `build/`":
  exec fmt"sass --no-source-map {styleDir / bin[0]}.sass {styleDir / bin[0]}.css"

task buildRelease, "Build release version":
  exec "nimble -d:danger build"

after build:
  finalizeTask()
  buildCssTask()
