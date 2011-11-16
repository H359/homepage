{-# LANGUAGE OverloadedStrings #-}
import Control.Arrow ((>>>))

import Text.Pandoc (WriterOptions, writerHtml5)
--import Data.Monoid (mempty)

import Hakyll

h359WriterOptions :: WriterOptions
h359WriterOptions = defaultHakyllWriterOptions {
    writerHtml5 = True
}

main :: IO() 
main = hakyll $ do
 -- Copy images
 match "images/*" $ do
    route idRoute
    compile copyFileCompiler

 -- Copy css
 match "css/*" $ do
    route idRoute
    compile compressCssCompiler

 -- Copy js
 match "js/*" $ do
    route idRoute
    compile copyFileCompiler

 -- templates
 match "templates/*" $ compile templateCompiler

 -- clients
 match "clients/*" $ do
    route $ setExtension "html"
    compile $ pageCompilerWith defaultHakyllParserState h359WriterOptions
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler
 --
 -- create "clients.html" $ constA mempty
 --   >>> applyTemplateCompiler "templates/clients.html"
 --   >>> applyTemplateCompiler "templates/default.html"
 --   >>> relativizeUrlsCompiler

 -- index.html
 match "index.markdown" $ do
    route $ setExtension "html"
    compile $ pageCompilerWith defaultHakyllParserState h359WriterOptions
        >>> setFieldPageList id "templates/clientitem.html" "clients" "clients/*"
        >>> applyTemplateCompiler "templates/home.html"
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler
