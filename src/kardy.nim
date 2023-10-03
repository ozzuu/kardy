include pkg/karax/prelude

import kardy/config
import kardy/base
import kardy/storage
import kardy/pages/settings as settingsPage
import kardy/pages/main as mainPage

import json

var
  settings = getSettings new Settings
  state = getState new State

# echo pretty %*settings

proc renderer: VNode =
  var hash = getHash()
  if not settings.configured:
    settings = getSettings settings
    if not settings.configured:
      hash = settingsRoute
      setHash hash

  # echo pretty %*state

  buildHtml tdiv:
    case hash:
      of settingsRoute:
        drawSettings settings
      else:
        drawMain settings, state

setRenderer renderer
