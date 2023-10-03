from std/dom import value, reload, window
from std/sugar import collect

include pkg/karax/prelude

import kardy/base
import kardy/config
import kardy/storage
import kardy/widgets

from pkg/util/forStr import tryParseFloat

proc addCardForm(settings: Settings; state: State): VNode =
  var selectedCard {.global.} = CardId -1
  buildHtml tdiv(class = "addCard"):
    text "Add Card to Deck"
    selectedCard.newCardSelect collect(
      for card in settings.cards:
        if not card.discarded state:
          if state.deck.count(card.id) < card.quantity:
            card
    )
    button:
      text "Add Card"
      proc onClick(ev: Event; n: VNode) =
        let cardId = selectedCard
        echo cardId
        if cardId >= 0:
          let maxCards = settings.cards.get(cardId).quantity
          if state.deck.count(cardId) < maxCards:
            state.deck.add cardId
            saveState state

proc addActionForm(settings: Settings; state: State): VNode =
  var probability: Probability
  let cards {.global.} = collect:
    for card in settings.cards:
      if card.disposable and not card.discarded state:
        card
  var
    discardCard {.global.} = CardId -1
    addProbabilityCard {.global.} = CardId -1
  buildHtml tdiv(class = "newAction"):
    tdiv(class = "discard"):
      text "Discard Card"
      discardCard.newCardSelect cards
      button:
        text "Discard"
        proc onClick(ev: Event; n: VNode) =
          let cardId = discardCard
          if cardId >= 0:
            state.addAction cardId.newAction Discard
            saveState state
    tdiv(class = "probability"):
      text "Add a new probability to card"
      addProbabilityCard.newCardSelect cards
      input(`type` = "number", step = "0.1", max = $high Probability,
            min = $low Probability, value = "0"):
        proc onInput(ev: Event; n: VNode) =
          probability = tryParseFloat $n.value
      button:
        text "Add"
        proc onClick(ev: Event; n: VNode) =
          let cardId = addProbabilityCard
          echo cardId
          if cardId >= 0:
            state.addAction cardId.newAction(NewProbability, probability)
            saveState state

proc undoForm(settings: Settings; state: State): VNode =
  buildHtml tdiv(class = "undo"):
    if state.actions.len > 0:
      p:
        text "Last action:"
        p:
          bold:
            text $state.actions[^1].kind
            text " for card "
            text settings.cards.get(state.actions[^1].cardId).name

      button:
        text "Undo"
        proc onClick(ev: Event; n: VNode) =
          discard pop state.actions
          saveState state



proc drawMain*(settings: Settings; state: State): VNode =
  buildHtml tdiv(class = "main"):
    h1: text "Kardy"

    tdiv(class = "menu"):
      addCardForm settings, state
      tdiv(class = "actions"):
        addActionForm settings, state
        undoForm settings, state

    tdiv(class = "deck"):
      tdiv(class = "title"): text "Deck"
      tdiv(class = "cards"):
        for i in 0..<state.deck.len:
          let
            cardId = state.deck[i]
            card = settings.cards.get cardId
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
