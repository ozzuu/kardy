type
  CardId* = distinct int
  CardSetting* = ref object
    ## Settings for a card
    id*: CardId
    name*, description*: string
    quantity*: int = 1
    disposable*: bool
  Settings* = ref object
    ## Settings, stored in hash
    configured*: bool
    cards*: seq[CardSetting]

  Probability* = range[-1.0..1.0]

  ActionKind* {.pure.} = enum
    ## The types of actions
    Discard = 0, NewProbability
  Action* = ref object
    ## Action taken in the game
    cardId*: CardId
    case kind*: ActionKind
      of NewProbability:
        probability*: Probability
      of Discard: discard
  State* = ref object
    ## Your current game data, stored in LocalStorage
    deck*: seq[CardId]
    actions*: seq[Action]


  CardState* = ref object
    ## This object holds the state of the card in game
    id*: CardId
    probabilities*: seq[Probability]
    discarded*: bool

  CardsState* = seq[CardState]

using
  id: CardId
  card: CardSetting
  settings: Settings
  state: State
  cardsState: CardsState

converter cardIdToInt*(id): int =
  int id

func get*(cards: seq[CardSetting]; id): CardSetting =
  new result
  for card in cards:
    if id == card.id:
      return card
func get*(cardsState; id): CardState =
  new result
  for cardState in cardsState:
    if id == cardState.id:
      return cardState

func newAction*(id; kind: ActionKind; prob: Probability = 0.0): Action =
  new result
  result.cardId = id
  result.kind = kind
  case kind:
    of NewProbability:
      result.probability = prob
    of Discard: discard

func discarded*(card; state): bool =
  for action in state.actions:
    if action.kind == Discard and action.cardId == card.id:
      return true

func calculateCardsState*(settings, state): CardsState =
  for cardId in state.deck:
    var cardState = new CardState
    cardState.id = cardId
    result.add cardState

  for action in state.actions:
    let cardState = result.get action.cardId
    case action.kind:
      of Discard:
        cardState.discarded = true
      of NewProbability:
        cardState.probabilities.add action.probability

func summary*(probs: seq[Probability]): Probability =
  var sum: float
  for prob in probs:
    sum += prob
  if probs.len > 0:
    result = sum / float probs.len
