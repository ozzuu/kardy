from std/dom import value,  OptionElement
include pkg/karax/prelude

import kardy/base


const selectTitleValue = "default"

proc newCardSelect*(cards: seq[CardSetting]; title = "Select the Card"): VNode =
  result = buildHtml select:
    option(selected = "", value = selectTitleValue): text title
    for card in cards:
      option(value = $card.id):
        text card.name
      proc onChange(ev: Event; n: VNode) =
        result.value = ev.target.value
  result.value = selectTitleValue

proc unselect*(select: VNode) =
  select.value = selectTitleValue
