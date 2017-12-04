{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DeriveGeneric #-}

module Handler.ImportSet where

import Import
import Yesod.Form.Bootstrap3
import Data.Conduit.Binary
import qualified Data.Vector as V
import Data.Csv
import GHC.Generics (Generic)

data Row = Row { front :: Text, back :: Text, hint :: Text }
    deriving (Generic, Show)
instance FromRecord Row
instance ToRecord Row    

data ImportedSet = ImportedSet { 
    file :: FileInfo, 
    name :: Text,
    description :: Text
    }

fileUploadForm :: AForm Handler ImportedSet
fileUploadForm = ImportedSet
    <$> areq fileField (bfs ("File" :: Text)) Nothing
    <*> areq textField (bfs ("Name" :: Text)) Nothing
    <*> areq textField (bfs ("Description" :: Text)) Nothing


getImportSetR :: Handler Html
getImportSetR = do
  (subFormWidget, enctype) <- generateFormPost $ renderBootstrap3 BootstrapBasicForm fileUploadForm
  defaultLayout $ do
      [whamlet|
        <form .ui.form method=post action=@{ImportSetR} enctype=#{enctype}>
            ^{subFormWidget}
            <button> Upload
      |]

postImportSetR :: Handler Html
postImportSetR = do
    ((result, _), _) <- runFormPost $ renderBootstrap3 BootstrapBasicForm fileUploadForm
    case result of
        FormSuccess (ImportedSet res name desc) -> do
            fcSetId <- runDB $ insert $ FlashCardSet name desc
            bytes <- runResourceT $ fileSource res $$ sinkLbs
            case decode NoHeader bytes of
                Left err -> defaultLayout $ do [whamlet| #{err} |]
                Right v -> do
                    V.forM_ v $ \(Row f b h) -> runDB $ insert $ FlashCard fcSetId f b h
                    redirect HomeR
        _ -> defaultLayout $ do [whamlet|
                Error code: form post error :(
            |]
