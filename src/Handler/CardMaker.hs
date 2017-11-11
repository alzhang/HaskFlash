{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.CardMaker where

import Import
import Yesod.Form.Bootstrap3

flashCardForm :: FlashCardSetId -> AForm Handler FlashCard
flashCardForm flashCardSetId = FlashCard
    <$> pure flashCardSetId
    <*> areq textField (bfs ("Front" :: Text)) Nothing
    <*> areq textField (bfs ("Back" :: Text)) Nothing
    <*> areq textField (bfs ("Hint" :: Text)) Nothing

getCardMakerR :: FlashCardSetId -> Handler Html
getCardMakerR flashCardSetId = do
    flashCardSet <- runDB $ get404 flashCardSetId
    (cardMakerWidget, enctype) <- generateFormPost $ renderBootstrap3 BootstrapBasicForm (flashCardForm flashCardSetId)
    defaultLayout $ do
        $(widgetFile "sets/card-maker")

postCardMakerR :: FlashCardSetId -> Handler Html
postCardMakerR flashCardSetId = error "Not yet implemented: postCardMakerR"
