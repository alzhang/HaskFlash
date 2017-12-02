{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}

module Handler.Game where

import Import
import Control.Lens
import Yesod.Form.Bootstrap3

data Submission = Submission { submission :: Text }

fetchedCard :: FlashCardSetId -> Int -> HandlerT App IO (Maybe (Entity FlashCard))
fetchedCard flashCardSetId cardIndex = 
    runDB $ do
        ps <- selectList ([FlashCardParent ==. flashCardSetId]) []
        return (ps ^? ix cardIndex)

cardsCount :: FlashCardSetId -> HandlerT App IO Int
cardsCount flashCardSetId = runDB $ count [FlashCardParent ==. flashCardSetId]

submissionForm :: AForm Handler Submission
submissionForm = Submission
    <$> areq textField (bfs ("submission" :: Text)) Nothing

renderCard :: FlashCardSetId -> Int -> Bool -> Handler Html
renderCard setIdx cardIdx correct = do
    (subFormWidget, enctype) <- generateFormPost $ renderBootstrap3 BootstrapBasicForm submissionForm
    maybeCard <- fetchedCard setIdx cardIdx
    defaultLayout $ do
        [whamlet|
            $maybe (Entity _ cardLiteral) <- maybeCard
                <div .ui.grid.middle.aligned.centered>
                    <div .ui.card>
                        <div .content>
                            <div .header>
                                #{flashCardFront cardLiteral}
                            $if not correct
                                <div .description>
                                    Hint: #{flashCardHint cardLiteral}
                        <div .extra>
                            <form .ui.form method=post action=@{GameR setIdx cardIdx} enctype=#{enctype}>
                                ^{subFormWidget}
            $nothing
                <h1> Completed - there are no more cards in the set!
        |]

getGameR :: FlashCardSetId -> Int -> Handler Html
getGameR flashCardSetId cardIndex = do
    renderCard flashCardSetId cardIndex True

postGameR :: FlashCardSetId -> Int -> Handler Html
postGameR flashCardSetId cardIndex = do
    ((res, _), _) <- runFormPost $ renderBootstrap3 BootstrapBasicForm submissionForm
    case res of
        FormSuccess sub -> do
            currentCard <- fetchedCard flashCardSetId cardIndex
            case currentCard of
              Nothing -> defaultLayout $ do
                 [whamlet|
                   Error code: Fuck Rex
                 |]
              Just (Entity _ cardLiteral) ->
                 if ((flashCardBack cardLiteral) == submission sub) then
                     redirect $ (GameR flashCardSetId (cardIndex + 1))
                 else
                     renderCard flashCardSetId cardIndex False
        _ -> defaultLayout $ do
           [whamlet|
             Error code: Form Submission fucked by Rex
           |]
