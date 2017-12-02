{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}

module Handler.Cards where

import Import

getCardsR :: FlashCardSetId -> Handler Html
getCardsR flashCardSetId = do
    flashcards <- runDB $ selectList ([FlashCardParent ==. flashCardSetId]) []
    defaultLayout $ do
        [whamlet|
            <div .ui.labeled.icon.fluid.two.item.menu>
                <a .item href="@{GameR flashCardSetId 0}">
                    Play
                <a .item href="@{ExportSetR flashCardSetId}">
                    <i .download.icon>
                    Export Sets

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
