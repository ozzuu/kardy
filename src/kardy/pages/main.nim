from std/dom import value, reload, window
from std/sugar import collect

include pkg/karax/prelude

import kardy/base
import kardy/config
import kardy/storage
import kardy/widgets

from pkg/util/forStr import tryParseInt, tryParseFloat

func cardIdValue(select: VNode): CardId =
  CardId tryParseInt $select.value

proc addCardForm(settings: Settings; state: State): VNode =
  let cardSelection = newCardSelect collect(
      for card in settings.cards:
        if not card.discarded state:
          if state.deck.count(card.id) < card.quantity:
            card
  )
  buildHtml tdiv(class = "addCard"):
    text "Add Card to Deck"
    cardSelection
    button:
      text "Add Card"
      proc onClick(ev: Event; n: VNode) =
        let selected = cardSelection.cardIdValue
        if selected >= 0:
          let maxCards = settings.cards.get(selected).quantity
          if state.deck.count(selected) < maxCards:
            state.deck.add selected
            unselect cardSelection
            saveState state
            redrawSync()

proc addActionForm(settings: Settings; state: State): VNode =
  var
    probability: Probability
  let
    cards = collect:
      for card in settings.cards:
        if card.disposable and not card.discarded state:
          card
    discardCardSel = newCardSelect cards
    addProbabCardSel = newCardSelect cards
  buildHtml tdiv(class = "newAction"):
    tdiv(class = "discard"):
      text "Discard Card"
      discardCardSel
      button:
        text "Discard"
        proc onClick(ev: Event; n: VNode) =
          let cardId = discardCardSel.cardIdValue
          if cardId >= 0:
            state.addAction cardId.newAction Discard
            for i in countdown(state.deck.len - 1, 0):
              if cardId == state.deck[i]:
                state.deck.delete i
            saveState state
    tdiv(class = "probability"):
      text "Add a new probability to card"
      addProbabCardSel
      input(`type` = "number", step = "0.1", max = $high Probability,
            min = $low Probability, value = "0"):
        proc onInput(ev: Event; n: VNode) =
          probability = tryParseFloat $n.value
      button:
        text "Add"
        proc onClick(ev: Event; n: VNode) =
          let cardId = addProbabCardSel.cardIdValue
          if cardId >= 0:
            state.addAction cardId.newAction(NewProbability, probability)
            saveState state

proc drawMain*(settings: Settings; state: State): VNode =
  buildHtml tdiv(class = "main"):
    h1: text "Kardy"

    tdiv(class = "actions"):
      addCardForm settings, state
      br()
      addActionForm settings, state

    tdiv(class = "deck"):
      tdiv(class = "title"): text "Deck"
      tdiv(class = "cards"):
        for i in 0..<state.deck.len:
          let
            cardId = state.deck[i]
            card = settings.cards.get cardId
            probabilities = card.probabilities state

          tdiv(class = "card"):
            span(class = "name"):
              text card.name
            p(class = "description"):
              text card.description
            tdiv(class = "probabilities"):
              tdiv(class = "title"): text "Probabilities"
              if probabilities.len > 0:
                for probability in probabilities:
                  tdiv(class = "probability"):
                    text $probability
            tdiv(class = "totalProbability"):
              if probabilities.len > 0:
                tdiv(class = "title"): text "Probability"
                bold: text $probabilities.summary
            button(class = "delete", index = i):
              text "Delete"
              proc onClick(ev: Event; n: VNode) =
                state.deck.delete n.index
                saveState state

    tdiv(class = "gameCards"):
      tdiv(class = "title"): text "Game cards"
      tdiv(class = "cards"):
        for i in 0..<settings.cards.len:
          let card = settings.cards[i]
          if not card.discarded state:
            let probabilities = card.probabilities state
            tdiv(class = "card"):
              span(class = "name"):
                text card.name
              p(class = "description"):
                text card.description
              tdiv(class = "probabilities"):
                tdiv(class = "title"): text "Probabilities"
                if probabilities.len > 0:
                  for probability in probabilities:
                    tdiv(class = "probability"):
                      text $probability
              tdiv(class = "totalProbability"):
                if probabilities.len > 0:
                  tdiv(class = "title"): text "Probability"
                  bold: text $probabilities.summary

    hr()

    a(href = "#" & settingsRoute):
      text "Cards settings"
    button(class = "resetState"):
      text "Reset state"
      proc onClick(ev: Event; n: VNode) =
        saveState new State
        reload window.location
