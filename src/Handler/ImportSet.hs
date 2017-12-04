{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}

module Handler.ImportSet where

import Import
import Yesod.Form.Bootstrap3

fileUploadForm :: AForm Handler FileInfo
fileUploadForm = fileAFormReq "Required file"


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
     FormSuccess res -> do
          let a = fileName res
          defaultLayout $ do [whamlet|
                 ^{a}
               |]
     _ -> defaultLayout $ do [whamlet|
            Error code: Rex fucks it up again...
          |]
