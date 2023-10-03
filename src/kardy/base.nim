from std/strformat import fmt

type
  CardId* = distinct int
  PlayerId* = distinct int
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
    players*: Natural = 1

  Percentage* = range[-1.0..1.0]

  ActionKind* {.pure.} = enum
    ## The types of actions
    Discard = 0, NewBet
  Bet* = ref object
    playerId*: PlayerId
    trustability*: Percentage
  Action* = ref object
    ## Action taken in the game
    cardId*: CardId
    case kind*: ActionKind
      of NewBet:
        bet*: Bet
      of Discard: discard
  State* = ref object
    ## Your current game data, stored in LocalStorage
    deck*: seq[CardId]
    actions*: seq[Action]

using
  cardId: CardId
  playerId: PlayerId
  card: CardSetting
  settings: Settings
  state: State
  action: Action
  bet: Bet

converter cardIdToInt*(cardId): int =
  int cardId
converter playerIdToInt*(playerId): int =
  int playerId

func get*(cards: seq[CardSetting]; cardId): CardSetting =
  new result
  for card in cards:
    if cardId == card.id:
      return card

func newAction*(
  cardId;
  kind: ActionKind;
  # NewBet
  playerId = PlayerId 1;
  trustability: Percentage = 1
): Action =
  new result
  result.cardId = cardId
  result.kind = kind
  case kind:
    of NewBet:
      if playerId > 0:
        var bet = new Bet
        bet.trustability = trustability
        bet.playerId = playerId
        result.bet = bet
    of Discard: discard

func discarded*(card; state): bool =
  for action in state.actions:
    if action.kind == Discard and action.cardId == card.id:
      return true

func bets*(card; state): seq[Bet] =
  for action in state.actions:
    if action.kind == NewBet:
      if action.cardId == card.id:
        result.add action.bet

func summary*(bets: seq[Bet]; settings): Percentage =
  if bets.len > 0:
    var sums: seq[tuple[qnt: int; total: float]]
    for _ in 1..settings.players:
      sums.add (0, 0.0)
    for bet in bets:
      let
        i = bet.playerId - 1
        sum = sums[i]
      sums[i] = (
        sum.qnt + 1,
        sum.total + bet.trustability
      )
    var sum = 0.0
    for s in sums:
      if s.total > 0:
        sum += s.total / float s.qnt
    if sum > 0:
      result = sum / float sums.len

func `==`*(a, b: Action): bool =
  block itsSame:
    if a.kind != b.kind:
      break itsSame
    if a.kind == NewBet:
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
  for cardId in deck:
    if card == cardId:
      inc result

func pretty*(action; settings): string =
  let cardName = settings.cards.get(action.cardId).name
  case action.kind:
    of Discard:
      result = fmt"Discarded {cardName}"
    of NewBet:
      result = fmt"New bet from player {action.bet.playerId} for {cardName} with {int action.bet.trustability * 100}% of trustability"

func `$`*(bet): string =
  fmt"P{bet.playerId}: {int bet.trustability * 100}% of trust"
