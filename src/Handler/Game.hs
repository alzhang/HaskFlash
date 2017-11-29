{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}

module Handler.Game where

import Import

getGameR :: FlashCardSetId -> Handler Html
getGameR flashCardSetId = do
    firstCard <- runDB $ do
      ps <- selectFirst ([FlashCardParent ==. flashCardSetId]) []
      return ps
    case firstCard of
      Nothing -> defaultLayout $ do
         [whamlet|
           fuck rex
         |]
      Just (Entity cardId cardLiteral) ->
          defaultLayout $ do
              [whamlet|
                  <div .ui.card>
                      <div .content>
                          <div .header>
                              #{flashCardFront cardLiteral}
                          <div .description>
                              <b>Answer</b>: #{flashCardBack cardLiteral}
                      <div .extra.content>
                          <span .left.floated>
                              Hint: #{flashCardHint cardLiteral}
              |]
