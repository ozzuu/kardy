from std/dom import checked

include pkg/karax/prelude

import kardy/base
import kardy/storage

from pkg/util/forStr import tryParseInt

const minCards = 1

proc drawSettings*(settings: Settings): VNode =
  let oldSettings = settings.encodeSettings
  settings.configured = false
  proc addCard =
    var card = new CardSetting
    card.id = CardId settings.cards.len
    settings.cards.add card
  while settings.cards.len < minCards:
    addCard()
  result = buildHtml tdiv(class = "settings"):
    h1: text "Kardy Settings"
    tdiv(class = "cards"):
      tdiv(class="operations"):
        button(class = "add"):
          text "Add new card"
          proc onClick(ev: Event; n: VNode) =
            addCard()

      tdiv(class = "cardList"):
        for i in 0..<settings.cards.len:
          let card = settings.cards[i]
          tdiv(class = "card"):
            span(class = "id"):
              text "Card ID: "
              bold: text $card.id
            input(placeholder = "Card Name", class = "name", minlength = "1",
                  value = card.name, index = i):
              proc onInput(ev: Event; n: VNode) =
                settings.cards[n.index].name = $n.value
            textarea(placeholder = "Card Description", class = "description", minlength = "1",
                  value = card.description, index = i):
              proc onInput(ev: Event; n: VNode) =
                settings.cards[n.index].description = $n.value
            input(placeholder = "Card quantity", class = "name", `type` = "number",
                  min = "1", value = $card.quantity, index = i):
              proc onInput(ev: Event; n: VNode) =
                settings.cards[n.index].quantity = tryParseInt($n.value, 1)
            label(class = "disposable"):
              input(`type` = "checkbox", checked = toChecked(card.disposable),
                    index = i):
                proc onChange(ev: Event; n: VNode) =
                  let card = settings.cards[n.index]
                  card.disposable = not card.disposable
              text "Disposable"
            button(class = "delete", tabindex = "-1", index = i):
              text "Delete card"
              proc onClick(ev: Event; n: VNode) =
                settings.cards.delete n.index
      tdiv(class = "players"):
        input(placeholder = "Player quantity (without you)", `type` = "number",
              min = "1", value = $settings.players):
          proc onInput(ev: Event; n: VNode) =
            settings.players = tryParseInt($n.value, 1)

      button(class = "done"):
        text "Done"
        proc onClick(ev: Event; n: VNode) =
          for card in settings.cards:
            if card.name.len < 1 or card.quantity < 1:
              return
          settings.configured = true
          saveSettings settings
      button(class = "cancel"):
        text "Cancel"
        proc onClick(ev: Event; n: VNode) =
          settings[] = oldSettings.decodeSettings[]
          saveSettings settings
