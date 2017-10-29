{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.SetNew where

import Import
import Yesod.Form.Bootstrap3

flashCardSetForm :: AForm Handler FlashCardSet
flashCardSetForm = FlashCardSet
    <$> areq textField (bfs ("Name" :: Text)) Nothing
    <*> areq textField (bfs ("Description" :: Text)) Nothing

getSetNewR :: Handler Html
getSetNewR = do
    (widget, enctype) <- generateFormPost $ renderBootstrap3 BootstrapBasicForm flashCardSetForm
    defaultLayout $ do
        $(widgetFile "sets/new")

postSetNewR :: Handler Html
postSetNewR = do
    ((res, widget), enctype) <- runFormPost $ renderBootstrap3 BootstrapBasicForm flashCardSetForm
    case res of 
        FormSuccess fcSet -> do
            fcSetID <- runDB $ insert fcSet
            redirect $ HomeR
        _ -> defaultLayout $(widgetFile "sets/new")
