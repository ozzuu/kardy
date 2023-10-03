from std/dom import value, `value=`
include pkg/karax/prelude

import kardy/base


proc renderSelects(selected: var kstring; options: seq[string]): VNode =
  buildHtml tdiv:
    hr()
    h2: text "works just at firefox"
    select:
      for opt in options:
        option(value = opt):
          text opt
          proc onClick(ev: Event; n: VNode) =
            selected = n.value
            redrawSync()
    h2: text "correct way not working (after pop)" # https://stackoverflow.com/questions/9972280/onclick-on-option-tag-not-working-on-ie-and-chrome
    select:
      for opt in options:
        option(value = opt):
          text opt
      proc onChange(ev: Event; n: VNode) =
        selected = n.value
        redrawSync()


var
  options = @["Hitipag", "Zonuun", "Hetedejed", "Belwaen", "Waimelo", "Pawamu"]

proc renderer: VNode =
  var selected {.global.} = kstring "Nothing selected"
  buildHtml tdiv:
    p:
      text "Selected: "
      bold: text selected
    ol:
      text "options: "
      for option in options:
        li: text option
    button:
      text "Pop option"
      proc onClick(ev: Event; n: VNode) =
        discard pop options
    selected.renderSelects options

setRenderer renderer
