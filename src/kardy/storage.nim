from std/dom import window, getItem, setItem
from std/base64 import encode, decode
from std/json import `$`, parseJson, to
from std/jsonutils import toJson

import kardy/types
import kardy/config

proc setHash*(s: string) =
  window.location.hash = cstring s
proc getHash*: string =
  result = $window.location.hash
  result = if result.len > 1: result[1..^1] else: ""

proc encodeSettings*(s: Settings): string =
  encode $s.toJson
proc decodeSettings*(s: string): Settings =
  s.decode.parseJson.to Settings

proc saveSettings*(s: Settings) =
  setHash s.encodeSettings
proc getSettings*(default: Settings): Settings =
  try:
    result = getHash().decodeSettings
  except:
    result = default
    
proc getState*(default: State): State =
  try:
    result = window.localStorage.getItem(localStorageStateKey).`$`.parseJson.to State
  except:
    result = default
