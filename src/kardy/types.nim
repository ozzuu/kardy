type
  CardId* = distinct int
  CardSetting* = ref object
    ## Settings for a card
    id*: CardId
    name*: string
    quantity*: int = 1
  Settings* = ref object
    ## Settings, stored in hash
    configured*: bool
    cards*: seq[CardSetting]

  Info* = ref object
    ## Info taken in the game
    kind*: InfoKind
    cardId*: CardId
    probability*: range[0.0..1.0]
  InfoKind* {.pure.} = enum
    ## The types of Info
    ConsiderInGuessing, DisconsiderInGuessing

  State* = ref object
    ## Your current game data, stored in LocalStorage
    deck*: seq[CardId]
    infos*: seq[Info]

converter cardIdToInt*(id: CardId): int =
  int id

func get*(cards: seq[CardSetting]; cardId: CardId): CardSetting =
  new result
  for card in cards:
    if cardId == card.id:
      return card
