{-# LANGUAGE OverloadedStrings #-}
module Reporting.Exit.Help
  ( Report
  , report
  , docReport
  , jsonReport
  , compilerReport
  , reportToDoc
  , reportToJson
  , toString
  , toStdout
  , toStderr
  )
  where


import qualified Data.Utf8 as Utf8
import GHC.IO.Handle (hIsTerminalDevice)
import System.IO (Handle, hPutStr, stderr, stdout)

import qualified Json.Encode as E
import Json.Encode ((==>))
import Reporting.Doc ((<+>))
import qualified Reporting.Doc as D
import qualified Reporting.Exit.Compile as Compile



-- REPORT


data Report
  = CompilerReport Compile.Exit [Compile.Exit]
  | Report
      { _title :: String
      , _path :: Maybe FilePath
      , _message :: D.Doc
      }


report :: String -> Maybe FilePath -> String -> [D.Doc] -> Report
report title path startString others =
  Report title path $ D.stack (D.reflow startString:others)


docReport :: String -> Maybe FilePath -> D.Doc -> [D.Doc] -> Report
docReport title path startDoc others =
  Report title path $ D.stack (startDoc:others)


jsonReport :: String -> Maybe FilePath -> D.Doc -> Report
jsonReport =
  Report


compilerReport :: Compile.Exit -> [Compile.Exit] -> Report
compilerReport =
  CompilerReport



-- TO DOC


reportToDoc :: Report -> D.Doc
reportToDoc report_ =
  case report_ of
    CompilerReport e es ->
      Compile.toDoc e es

    Report title maybePath message ->
      let
        makeDashes n =
          replicate (max 1 (80 - n)) '-'

        errorBarEnd =
          case maybePath of
            Nothing ->
              makeDashes (4 + length title)

            Just path ->
              makeDashes (5 + length title + length path) ++ " " ++ path

        errorBar =
          D.dullcyan $
            "--" <+> D.fromChars title <+> D.fromChars errorBarEnd
      in
        D.stack [errorBar, message, ""]



-- TO JSON


reportToJson :: Report -> E.Value
reportToJson report_ =
  case report_ of
    CompilerReport e es ->
      E.object
        [ "type" ==> E.string "compile-errors"
        , "errors" ==> E.list Compile.toJson (e:es)
        ]

    Report title maybePath message ->
      E.object
        [ "type" ==> E.string "error"
        , "path" ==> maybe E.null (E.string . Utf8.fromChars) maybePath
        , "title" ==> E.string (Utf8.fromChars title)
        , "message" ==> D.encode message
        ]



-- OUTPUT


toString :: D.Doc -> String
toString =
  D.toString


toStdout :: D.Doc -> IO ()
toStdout doc =
  toHandle stdout doc


toStderr :: D.Doc -> IO ()
toStderr doc =
  toHandle stderr doc


toHandle :: Handle -> D.Doc -> IO ()
toHandle handle doc =
  do  isTerminal <- hIsTerminalDevice handle
      if isTerminal
        then D.toAnsi handle doc
        else hPutStr handle (toString doc)
