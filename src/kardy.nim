include pkg/karax/prelude

import kardy/config
import kardy/types
import kardy/storage
import kardy/models/settings as settingsPage
import kardy/models/main as mainPage

var
  settings = new Settings
  state: State

proc renderer: VNode =
  var hash = getHash()
  settings = getSettings settings
  if not settings.configured:
    hash = settingsRoute
    setHash hash

  echo settings[]

  buildHtml(tdiv):
    case hash:
      of settingsRoute:
        drawSettings settings
      else:
        drawMain settings, state

setRenderer renderer
