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
    flashcards <- runDB $ selectList ([FlashCardParent ==. flashCardSetId]) []
    defaultLayout $ do
        [whamlet| 
            <div .ui.four.cards>
                $forall Entity _ card <- flashcards
                    <div .ui.card>
                        <div .content>
                            <div .header>
                                #{flashCardFront card}
                            <div .description>
                                <b>Answer</b>: #{flashCardBack card}
                        <div .extra.content>
                            <span .left.floated>
                                Hint: #{flashCardHint card}
        |]
    
