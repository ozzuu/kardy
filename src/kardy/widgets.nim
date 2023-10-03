from std/dom import value, `value=`
include pkg/karax/prelude

from pkg/util/forStr import tryParseInt

import kardy/base


proc newCardSelect*(value: var CardId; cards: seq[CardSetting]; title = "Select the Card"): VNode =
  result = buildHtml select(value = ""):
    option(selected = "", value = ""):
      text title
    for card in cards:
      option(value = $card.id):
        text card.name
    proc onChange(ev: Event; n: VNode) =
      value = CardId tryParseInt $n.value
