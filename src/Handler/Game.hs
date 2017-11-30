{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}

module Handler.Game where

import Import
import Control.Lens

getGameR :: FlashCardSetId -> Int -> Handler Html
getGameR flashCardSetId cardIndex = do
    firstCard <- runDB $ do {
                             ; ps <- selectList ([FlashCardParent ==. flashCardSetId]) []
                             ; return (ps ^? ix cardIndex)
                            }

    case firstCard of
      Nothing -> defaultLayout $ do
         [whamlet|
           fuck rex
         |]
      Just (Entity cardId cardLiteral) ->
          defaultLayout $ do
              [whamlet|
                  <div .ui.grid.middle.aligned.centered>
                    <div .ui.card height=800>
                        <div .content>
                            <div .header>
                                #{flashCardFront cardLiteral}
                            <div .description>
                                <b>Answer</b>: #{flashCardBack cardLiteral}
                            <form method=get action=@{GameR flashCardSetId (cardIndex + 1)}>
                                <button .ui.primary.button> Next
              |]
