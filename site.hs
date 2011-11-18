{-# LANGUAGE OverloadedStrings #-}
import Control.Arrow ((>>>))

import Text.Pandoc (WriterOptions, writerHtml5)
--import Data.Monoid (mempty)

import Hakyll

h359WriterOptions :: WriterOptions
h359WriterOptions = defaultHakyllWriterOptions {
    writerHtml5 = True
}

defaultPageCompiler = pageCompilerWith defaultHakyllParserState h359WriterOptions

config :: HakyllConfiguration
config = defaultHakyllConfiguration {
 deployCommand = "rsync --checksum -ave ssh _site/* h359.ru:h359.ru"
}

main :: IO() 
main = hakyllWith config $ do
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
    compile $ defaultPageCompiler
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
    compile $ defaultPageCompiler
        >>> setFieldPageList id "templates/clientitem.html" "clients" "clients/*"
        >>> applyTemplateCompiler "templates/home.html"
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler
