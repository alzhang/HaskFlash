# HaskFlash
> HaskFlash is a web app flashcard written in Haskell.
> Users can input sets of word pairs into the system and quiz themselves with random pairs.

Libraries used:
- [Yesod](https://www.yesodweb.com/)
- [Semantic UI](https://semantic-ui.com/)

## Features:
- [x] Create your own flashcards/flashcard sets
- [ ] Practice on your flashcards
    - [x] Enable Hints
    - [x] Enable answer validation to match back of flashcard
    - [ ] Enable timing
    - [ ] Enable audio hints
- [ ] Import/Export flashcard sets
- [ ] Authentication (Unique flashcard sets for users)

## Development Setup
```sh
git clone https://github.com/alzhang/HaskFlash
stack build
stack exec -- yesod devel
```
