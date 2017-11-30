{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
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
        [whamlet|
            <h1> Current Set: #{flashCardSetName flashCardSet}
            <form method=post action=@{CardMakerR flashCardSetId} enctype=#{enctype}>
                ^{cardMakerWidget}
                <button .ui.primary.button> Save
        |]

postCardMakerR :: FlashCardSetId -> Handler Html
postCardMakerR flashCardSetId = do
    ((res, _), _) <- runFormPost $ renderBootstrap3 BootstrapBasicForm (flashCardForm flashCardSetId)
    case res of
        FormSuccess flashCard -> do
            _ <- runDB $ insert flashCard
            rows <- runDB $ selectList [FlashCardParent ==. flashCardSetId] []
            defaultLayout $ do
                [whamlet|
                    <div .ui.success.message>
                        <div .header>FlashCard Completed
                        <p> You've added the card to your set!
                        <p> #{show flashCard}
                |]
                [whamlet|
                    <a href=@{CardMakerR flashCardSetId}>
                        <div .ui.primary.basic.button>
                            Add Another
                |]
                [whamlet|
                    <div .ui.labeled.button>
                        <a href=@{GameR flashCardSetId 0} .ui.positive.button>
                            <i .play.icon>
                            Play
                        <div .ui.green.basic.left.pointing.label>
                            #{length rows} Cards
                |]
        -- Error Handling
        _ -> defaultLayout [whamlet| <h1> looks like this was an error. |]
