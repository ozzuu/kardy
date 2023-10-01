include pkg/karax/prelude

import kardy/types
import kardy/config
import kardy/storage

from pkg/util/forStr import tryParseInt

proc drawMain*(settings: Settings; state: State): VNode =
  buildHtml(tdiv(class = "main")):
    h1: text "Kardy"
    a(href = "#" & settingsRoute):
      text "Settings"
