include pkg/karax/prelude

import kardy/base
import kardy/config
import kardy/storage

from pkg/util/forStr import tryParseInt, tryParseFloat


proc addCardForm(settings: Settings; state: State): VNode =
  var selected = CardId -1
  buildHtml tdiv(class = "addCard"):
    text "Add Card to Deck"
    select:
      option(selected = "", disabled = ""): text "Select the Card"
      for i in 0..<settings.cards.len:
        let card = settings.cards[i]
        if not card.discarded state:
          option(index = i):
            text card.name
            proc onClick(ev: Event; n: VNode) =
              selected = settings.cards[n.index].id
    button:
      text "Add Card"
      proc onClick(ev: Event; n: VNode) =
        if selected >= 0:
          let maxCards = settings.cards.get(selected).quantity
          var inDeck = 0
          for id in state.deck:
            if selected == id:
              inc inDeck
          if inDeck < maxCards:
            state.deck.add selected
            saveState state

proc addActionForm(settings: Settings; state: State): VNode =
  var
    # Discard
    discardCardId = CardId -1
    # Add probability
    probabilityCardId = CardId -1
    probability: Probability
  buildHtml tdiv(class = "newAction"):
    tdiv(class = "discard"):
      text "Discard Card"
      select:
        option(selected = "", disabled = ""): text "Select the Card"
        for i in 0..<settings.cards.len:
          let card = settings.cards[i]
          if card.disposable and not card.discarded state:
            option(index = card.id):
              text card.name
              proc onClick(ev: Event; n: VNode) =
                discardCardId = CardId n.index
      button:
        text "Discard"
        proc onClick(ev: Event; n: VNode) =
          if discardCardId >= 0:
            state.actions.add discardCardId.newAction Discard
            echo discardCardId
            for i in countdown(state.deck.len - 1, 0):
              if discardCardId == state.deck[i]:
                state.deck.delete i
            saveState state
    tdiv(class = "probability"):
      text "Add a new probability to card"
      select:
        option(selected = "", disabled = ""): text "Select the Card"
        for i in 0..<settings.cards.len:
          let card = settings.cards[i]
          if card.disposable and not card.discarded state:
            option(index = card.id):
              text card.name
              proc onClick(ev: Event; n: VNode) =
                probabilityCardId = CardId n.index
      input(`type` = "number", step = "0.1", max = $high Probability,
            min = $low Probability, value = "0"):
        proc onInput(ev: Event; n: VNode) =
          probability = tryParseFloat $n.value

      button:
        text "Add"
        proc onClick(ev: Event; n: VNode) =
          if probabilityCardId >= 0:
            state.actions.add probabilityCardId.newAction(NewProbability, probability)
            saveState state

proc drawMain*(settings: Settings; state: State): VNode =
  var cardsState = calculateCardsState(settings, state)
  buildHtml tdiv(class = "main"):
    h1: text "Kardy"

    tdiv(class = "actions"):
      addCardForm settings, state
      br()
      addActionForm settings, state

    tdiv(class = "deck"):
      for i in 0..<state.deck.len:
        let
          cardId = state.deck[i]
          card = settings.cards.get cardId
          cardState = cardsState.get cardId

        tdiv(class = "card"):
          span(class = "name"):
            text card.name
          p(class = "description"):
            text card.description
          tdiv(class = "probabilities"):
            tdiv(class = "title"): text "Probabilities"
            if cardState.probabilities.len > 0:
              tdiv(class = "parts"):
                tdiv(class = "title"): text "Parts"
                for probability in cardState.probabilities:
                  tdiv(class = "probability"):
                    text $probability
              tdiv(class = "total"):
                tdiv(class = "title"): text "Total"
                bold: text $cardState.probabilities.summary
          button(class = "delete", index = i):
            text "Delete"
            proc onClick(ev: Event; n: VNode) =
              state.deck.delete n.index
              saveState state

    hr()

    a(href = "#" & settingsRoute):
      text "Cards settings"
    button(class = "resetState"):
      text "Reset state"
      proc onClick(ev: Event; n: VNode) =
        saveState new State
