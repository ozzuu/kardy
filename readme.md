<div align=center>

# Kard

#### Cards Games Strategist

</div>

## About

This serverless application helps you in card based games.

This application is intended to be helpful in various card games, but for now,
the main focus is implement for the game Clue/Cluedo and related card guessing games.

## Features

### Own deck

You configure your own deck by setting what cards are yours.

### Guessing helper

If you need to guess a card combination that no one have (like in Cluedo game)
the application will help you!

If someone guess a card combination, you inform the application with a
probability of being a bluff.

All this data will be considered when helping you guess.

### Sneak peeks

You can also report your peeks, and if you're not sure what the card is you saw,
you can select multiple cards and they would be avoided

### Technical

#### Game config

You can easily configure any game card, add or remove them and share it!

All configurations is saved in URL hash, so you can share or save the config
by just copying the URL!

You can configure:

- Available cards in game.
<!-- - If cards can be discarded forever -->

#### Current game state saving

Your current game state is saved at LocalStorage!

## Dependencies

```bash
npm install -g uglify-js sass
```

## Contribute!

You can suggest a feature that can be helpful to a game in issues tab or create
an pull request!
## TODO

- [ ] Add categories to cards
  - [ ] Card selection separated by categories with `<optgroup>` HTML element
- [ ] Suggestion of already informed players at new bet player field

## License

This application is libre licensed over GPL-3
