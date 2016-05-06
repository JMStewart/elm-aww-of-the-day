module Aww where

import Graphics.Element exposing (..)
import Html exposing (img, text, div, source, video, Html)
import Html.Attributes exposing (..)
import Http
import Task exposing (..)
import Json.Decode as Json exposing ((:=))
import String
import Regex exposing (regex, replace, HowMany)

type alias Post =
  { title : String
  , post_hint : Maybe String
  , url : String
  , preview : Maybe String
  }

type alias Posts =
  List Post

initPost : Post
initPost =
  {title = "Help"
  , post_hint = Nothing
  , url = ""
  , preview = Nothing
  }

initPosts : Posts
initPosts =
  [initPost]

jsonUrl : String
jsonUrl =
  "https://www.reddit.com/r/aww.json"

styles : List (String, String)
styles =
  [ ("width", "100%")
  , ("float", "left")
  , ("clear", "both")
  ]

main : Signal Html
main =
  Signal.map view result.signal

view : Posts -> Html
view posts =
  let
    goodPosts = List.filter validPost posts
  in
    --div [] (List.map buildElement goodPosts)
    div [] (List.map buildElement (List.take 1 goodPosts))

buildElement : Post -> Html
buildElement post =
  case post.post_hint of
    Just "rich:video" -> buildVideo post
    Just "image" -> buildImg post
    Just "link" -> buildLink post
    otherwise -> img [][]

buildImg : Post -> Html
buildImg post =
  img [style styles, src post.url, title post.title][]

buildLink : Post -> Html
buildLink post =
  img [style styles, src (Maybe.withDefault "" post.preview), title post.title][]

buildVideo : Post -> Html
buildVideo post =
  video [style styles, autoplay True, loop True, title post.title](createSources post)

createSources : Post -> List Html
createSources post =
  let
    source1 = replace Regex.All (regex "gifv") (\_ -> "mp4") (makeHttps post.url)
    source2 = replace Regex.All (regex "gifv") (\_ -> "webm") (makeHttps post.url)
  in [source [src source1][], source [src source2][]]

makeHttps : String -> String
makeHttps url =
  replace Regex.All (regex "^http:") (\_ -> "https:") url

hasUrl : Post -> Bool
hasUrl post =
  not (String.isEmpty post.url)

hasPreview : Post -> Bool
hasPreview post =
  not (String.isEmpty (Maybe.withDefault "" post.preview))

validVideo : Post -> Bool
validVideo post =
  (Maybe.withDefault "" post.post_hint) == "rich:video" || String.endsWith ".gifv" post.url

validLink : Post -> Bool
validLink post =
  (Maybe.withDefault "" post.post_hint) == "link" && hasPreview post

validImg : Post -> Bool
validImg post =
  (Maybe.withDefault "" post.post_hint) == "image" && hasUrl post

validPost : Post -> Bool
validPost post =
  validVideo post || validLink post || validImg post

processJson : Json.Decoder Posts
processJson =
  Json.at ["data", "children"] (Json.list getData)

getData : Json.Decoder Post
getData =
  "data" := processPost

processPost : Json.Decoder Post
processPost =
  Json.object4 Post
    ("title" := Json.string)
    (Json.maybe ("post_hint" := Json.string))
    ("url" := Json.string)
    (Json.maybe (Json.at ["preview", "images", "0", "source", "url"] Json.string))

result : Signal.Mailbox Posts
result =
  Signal.mailbox []

report : Posts -> Task x ()
report str =
  Signal.send result.address str

port getJson : Task Http.Error ()
port getJson =
  Http.get processJson jsonUrl `andThen` report
