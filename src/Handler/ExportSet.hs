{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}


module Handler.ExportSet where

import Import
import Data.Text as Text

transformCards :: [Entity FlashCard] -> [Text]
transformCards cards =
    Import.map (\itemEntity -> transformCard $ entityVal itemEntity) cards

transformCard :: FlashCard -> Text
transformCard card =
     Text.concat [
       flashCardFront card
      , ","
      , flashCardBack card
      , ","
      , flashCardHint card
      , ","
      , "\n"
      ]

getExportSetR :: FlashCardSetId -> Handler Html
getExportSetR flashCardSetId = do
    setNameEntity <- runDB $ get404 flashCardSetId
    allCards <- runDB $ selectList [FlashCardParent ==. flashCardSetId] []
    let filename =  "export.csv"
    addHeader "Content-Disposition" $ Text.concat
        [ "attachment; filename=\"", filename, "\""]
    let body = Text.concat [
                            flashCardSetName setNameEntity
                           , ","
                           , "\n"
                           , (Text.concat (transformCards allCards))
                           ]
    sendResponse (typePlain, toContent $ body)
