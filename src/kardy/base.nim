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

using
  id: CardId
  card: CardSetting
  settings: Settings
  state: State

converter cardIdToInt*(id): int =
  int id

func get*(cards: seq[CardSetting]; id): CardSetting =
  new result
  for card in cards:
    if id == card.id:
      return card

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

func probabilities*(card; state): seq[Probability] =
  for action in state.actions:
    if action.kind == NewProbability:
      if action.cardId == card.id:
        result.add action.probability

func summary*(probs: seq[Probability]): Probability =
  var sum: float
  for prob in probs:
    sum += prob
  if probs.len > 0:
    result = sum / float probs.len

func `==`*(a, b: Action): bool =
  block itsSame:
    if a.kind != b.kind:
      break itsSame
    if a.kind == NewProbability:
      break itsSame
    if a.cardId == b.cardId:
      return true
  result = false

func addAction*(state; action: Action) =
  block addAction:
    for act in state.actions:
      if act == action:
        break addAction
    state.actions.add action

func count*(deck: seq[CardId]; card: CardId): int =
  ## Count how much of the card in the deck
  for id in deck:
    if card == id:
      inc result
