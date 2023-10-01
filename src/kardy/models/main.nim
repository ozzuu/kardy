include pkg/karax/prelude

import kardy/types
import kardy/config
import kardy/storage

from pkg/util/forStr import tryParseInt


proc addCardForm(settings: Settings; state: State): VNode =
  var selected: CardId
  buildHtml tdiv(class = "addCard"):
    select:
      for i in 0..<settings.cards.len:
        let card = settings.cards[i]
        option(index = i):
          text card.name
          proc onClick(ev: Event; n: VNode) =
            selected = settings.cards[n.index].id
    button(class = "add"):
      text "Add Card"
      proc onClick(ev: Event; n: VNode) =
        state.deck.add selected

proc drawMain*(settings: Settings; state: State): VNode =
  buildHtml tdiv(class = "main"):
    h1: text "Kardy"

    tdiv(class = "deckTools"):
      addCardForm settings, state

    tdiv(class = "deck"):
      for i in 0..<state.deck.len:
        let
          cardId = state.deck[i]
          card = settings.cards.get cardId

        tdiv(class = "card"):
          span(class = "name"):
            text card.name
          button(class = "delete", index = i):
            text "Delete"
            proc onClick(ev: Event; n: VNode) =
              state.deck.delete n.index

    hr()

    a(href = "#" & settingsRoute):
      text "Settings"
