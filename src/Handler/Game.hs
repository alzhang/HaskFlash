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
            Need to Implement lol
        |]
    
