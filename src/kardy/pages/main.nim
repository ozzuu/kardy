from std/dom import value, reload, window
from std/sugar import collect
from std/strformat import fmt

include pkg/karax/prelude

import kardy/base
import kardy/config
import kardy/storage
import kardy/widgets

from pkg/util/forStr import tryParseFloat, tryParseInt

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
  var
    betPlayer: int
    betTrustability: Percentage = 1
  var
    discardCard {.global.} = CardId -1
    addBetCard {.global.} = CardId -1
  buildHtml tdiv(class = "newAction"):
    tdiv(class = "discard"):
      text "Discard Card"
      discardCard.newCardSelect  collect(
        for card in settings.cards:
          if card.disposable and not card.discarded state:
            card
      )
      button:
        text "Discard"
        proc onClick(ev: Event; n: VNode) =
          let cardId = discardCard
          if cardId >= 0:
            state.addAction cardId.newAction Discard
            saveState state
    tdiv(class = "bet"):
      text "Add a new user bet"
      addBetCard.newCardSelect collect(
        for card in settings.cards:
          if card.disposable and not card.discarded state:
            card
      )
      input(placeholder = "Player ID", `type` = "number", min = "1",
            max = $settings.players):
        proc onInput(ev: Event; n: VNode) =
          echo n.value
          echo tryParseInt $n.value
          betPlayer = tryParseInt $n.value
      input(placeholder = "Trust Level", `type` = "number", step = "0.1",
            max = $high Percentage, min = $low Percentage, value = "1"):
        proc onInput(ev: Event; n: VNode) =
          betTrustability = tryParseFloat $n.value
      button:
        text "Add"
        proc onClick(ev: Event; n: VNode) =
          let cardId = addBetCard
          if cardId >= 0:
            state.addAction cardId.newAction(
              NewBet,
              playerId = PlayerId betPlayer,
              trustability = betTrustability
            )
            saveState state

proc undoForm(settings: Settings; state: State): VNode =
  buildHtml tdiv(class = "undo"):
    if state.actions.len > 0:
      p:
        text "Last action:"
        p:
          bold:
            text state.actions[^1].pretty settings

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
      tdiv(class = "title"):
        text "Deck\t"
        sup: text fmt"{state.deck.len} cards"
      tdiv(class = "cards"):
        for i in 0..<state.deck.len:
          let
            cardId = state.deck[i]
            card = settings.cards.get cardId
          if not card.discarded state:
            let bets = card.bets state

            tdiv(class = "card"):
              span(class = "name"):
                text card.name
              p(class = "description"):
                text card.description
              tdiv(class = "bets"):
                tdiv(class = "title"): text "Bets"
                if bets.len > 0:
                  for bet in bets:
                    tdiv(class = "bet"):
                      text $bet
              tdiv(class = "probability"):
                if bets.len > 0:
                  tdiv(class = "title"): text "Probability"
                  bold: text $bets.summary settings
              button(class = "delete", index = i):
                text "Delete"
                proc onClick(ev: Event; n: VNode) =
                  state.deck.delete n.index
                  saveState state

    tdiv(class = "gameCards"):
      tdiv(class = "title"):
        text "Game cards\t"
        sup: text fmt"{settings.cards.len - state.deck.len} cards"
      tdiv(class = "cards"):
        for i in 0..<settings.cards.len:
          let card = settings.cards[i]
          if card.id notin state.deck:
            if not card.discarded state:
              let bets = card.bets state
              tdiv(class = "card"):
                span(class = "name"):
                  text card.name
                p(class = "description"):
                  text card.description
                tdiv(class = "bets"):
                  tdiv(class = "title"): text "Bets"
                  if bets.len > 0:
                    for bet in bets:
                      tdiv(class = "bet"):
                        text $bet
                tdiv(class = "probability"):
                  if bets.len > 0:
                    tdiv(class = "title"): text "probability"
                    bold: text $bets.summary settings

    hr()
    h1: text "Action History"
    ul:
      for action in state.actions:
        li: text action.pretty settings

    hr()

    a(href = "#" & settingsRoute):
      text "Settings"
    br()
    button(class = "resetState"):
      text "Reset state"
      proc onClick(ev: Event; n: VNode) =
        saveState new State
        reload window.location
