module ExampleViewer where

import Effects exposing (Effects, map, batch, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (forwardTo)
import RouteHash exposing (HashUpdate)


-- Note that the way we handle modularity here is a little more verbose than
-- is, strictly speaking, necessary -- if you want to see a more sophisticated
-- approach, take a look at my csrs-elm app. (In short, we would construct a
-- record for each `Example` and some inter-related functions to use those
-- records). But that can be a little hard to follow, so I thought I'd leave
-- things a little more verbose here for now.


-- Note that I'm renaming these locally for simplicity.
import Example1.Counter as Example1
import Example2.CounterPair as Example2
import Example3.CounterList as Example3
import Example4.CounterList as Example4
import Example5.RandomGif as Example5
import Example6.RandomGifPair as Example6
import Example7.RandomGifList as Example7
import Example8.SpinSquarePair as Example8


-- MODEL

-- We'll need to know which example we're showing at the moment.
type Example
    = Example1
    | Example2
    | Example3
    | Example4
    | Example5
    | Example6
    | Example7
    | Example8


-- We need to collect all the data that each example wants to track. Now, we
-- could do this in a couple of ways. If we want to remember all the data as we
-- display one thing or another, we would do this as a record. If we wanted to
-- only remember the data that we're currently looking at, we might do this as
-- a union type. I'll do it the record way for now.
--
-- In a real app, you are likely to divide the model into parts which are
-- "permanent" (in the sense that the app needs to remember them, no matter
-- what the user is looking at now), and parts that are "transient" (which need
-- to be remembered, but only while the user is looking at a particular thing).
-- So, in that cae, some things would be in a record, whereas other things would
-- be in a union type.
type alias Model =
    { example1 : Example1.Model
    , example2 : Example2.Model
    , example3 : Example3.Model
    , example4 : Example4.Model
    , example5 : Example5.Model
    , example6 : Example6.Model
    , example7 : Example7.Model
    , example8 : Example8.Model

    -- And, we need to track which example we're actually showing
    , currentExample : Example
    }


-- Now, to init our model, we have to collect each examples init
init : (Model, Effects Action)
init =
    let
        model =
            { example1 = Example1.init
            , example2 = Example2.init
            , example3 = Example3.init
            , example4 = Example4.init
            , example5 = fst Example5.init
            , example6 = fst Example6.init
            , example7 = fst Example7.init
            , example8 = fst Example8.init

            , currentExample = Example1
            }

        effects =
            batch
                -- We happen to know that examples 1 through 4
                -- have no effects defined.
                [ Effects.map Example5Action <| snd Example5.init
                , Effects.map Example6Action <| snd Example6.init
                , Effects.map Example7Action <| snd Example7.init
                , Effects.map Example8Action <| snd Example8.init
                ]
    
    in
        (model, effects)


-- UPDATE

type Action
    = Example1Action Example1.Action
    | Example2Action Example2.Action
    | Example3Action Example3.Action
    | Example4Action Example4.Action
    | Example5Action Example5.Action
    | Example6Action Example6.Action
    | Example7Action Example7.Action
    | Example8Action Example8.Action
    | ShowExample Example 
    | NoOp


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            ( model, Effects.none )

        ShowExample example ->
            ( { model | currentExample = example }
            , Effects.none
            )

        Example1Action subaction ->
            ( { model | example1 = Example1.update subaction model.example1 }
            , Effects.none
            )
            
        Example2Action subaction ->
            ( { model | example2 = Example2.update subaction model.example2 }
            , Effects.none
            )
            
        Example3Action subaction ->
            ( { model | example3 = Example3.update subaction model.example3 }
            , Effects.none
            )
            
        Example4Action subaction ->
            ( { model | example4 = Example4.update subaction model.example4 }
            , Effects.none
            )

        Example5Action subaction ->
            let
                result =
                    Example5.update subaction model.example5

            in
                ( { model | example5 = fst result }
                , Effects.map Example5Action <| snd result
                )

        Example6Action subaction ->
            let
                result =
                    Example6.update subaction model.example6

            in
                ( { model | example6 = fst result }
                , Effects.map Example6Action <| snd result
                )
        
        Example7Action subaction ->
            let
                result =
                    Example7.update subaction model.example7

            in
                ( { model | example7 = fst result }
                , Effects.map Example7Action <| snd result
                )
        
        Example8Action subaction ->
            let
                result =
                    Example8.update subaction model.example8

            in
                ( { model | example8 = fst result }
                , Effects.map Example8Action <| snd result
                )

-- VIEW

(=>) = (,)


view : Signal.Address Action -> Model -> Html
view address model =
    let
        viewExample =
            case model.currentExample of
                Example1 ->
                    Example1.view (forwardTo address Example1Action) model.example1

                Example2 ->
                    Example2.view (forwardTo address Example2Action) model.example2

                Example3 ->
                    Example3.view (forwardTo address Example3Action) model.example3

                Example4 ->
                    Example4.view (forwardTo address Example4Action) model.example4

                Example5 ->
                    Example5.view (forwardTo address Example5Action) model.example5

                Example6 ->
                    Example6.view (forwardTo address Example6Action) model.example6

                Example7 ->
                    Example7.view (forwardTo address Example7Action) model.example7

                Example8 ->
                    Example8.view (forwardTo address Example8Action) model.example8

        makeTitle (index, example, title) =
            let
                styleList =
                    if example == model.currentExample
                        then
                            [ "font-weight" => "bold",
                            , "color" => "black"
                            ]
                        else
                            [ "font-weight" => "normal"
                            , "color" => "blue"
                            , "cursor" => "pointer"
                            ]

                -- Note that we compose the full title out of some information the
                -- super-module knows about (the index) and some information the
                -- sub-module knows about (the title)
                fullTitle =
                    text <|
                        "Example " ++ (toString index) ++ ": " ++ title
                
                -- If we're already on a page, we don't have a click action
                clickAction =
                    if example == model.currentExample
                        then []
                        else [ onClick address (ShowExample example) ] 

            in
                p   ( style styleList :: clickAction ) 
                    [ fullTitle ]

        toc =
            div [] <|
                List.map makeTitle
                    [ ( 1, Example1, Example1.title )
                    , ( 2, Example2, Example2.title )
                    , ( 3, Example3, Example3.title )
                    , ( 4, Example4, Example4.title )
                    , ( 5, Example5, Example5.title )
                    , ( 6, Example6, Example6.title )
                    , ( 7, Example7, Example7.title )
                    , ( 8, Example8, Example8.title )
                    ]

    in
        div [ ]
                [ div [ class "column-1" ] [ toc ]
                , div [ class "column-2" ] [ viewExample ]
                ]
                    

-- Routing

-- So, the main thing we'll do here to start with is modify the hash to
-- indicate which example we're currently looking at. Note that we don't have
-- to check whether it has changed, because the elm-route-hash module will
-- check for that. So, in this case, we don't care about the previous value.
-- And, we can always return a HashUpdate, since it will only actually be
-- set when it changes.
delta2update : Model -> Model -> Maybe HashUpdate
delta2update previous current =
    case current.currentExample of
        Example1 ->
            -- First, we ask the submodule for a HashUpdate. Then, we use
            -- `map` to prepend something to the URL.
            RouteHash.map ((::) "example-1") <|
                Example1.delta2update previous.example1 current.example1

        Example2 ->
            RouteHash.map ((::) "example-2") <|
                Example2.delta2update previous.example2 current.example2

        Example3 ->
            RouteHash.map ((::) "example-3") <|
                Example3.delta2update previous.example3 current.example3

        Example4 ->
            RouteHash.map ((::) "example-4") <|
                Example4.delta2update previous.example4 current.example4

        Example5 ->
            RouteHash.map ((::) "example-5") <|
                Example5.delta2update previous.example5 current.example5

        Example6 ->
            RouteHash.map ((::) "example-6") <|
                Example6.delta2update previous.example6 current.example6

        Example7 ->
            RouteHash.map ((::) "example-7") <|
                Example7.delta2update previous.example7 current.example7

        Example8 ->
            RouteHash.map ((::) "example-8") <|
                Example8.delta2update previous.example8 current.example8


-- Here, we basically do the reverse of what delta2update does
location2action : List String -> List Action
location2action list =
    case list of
        "example-1" :: rest ->
            -- We give the Example1 module a chance to interpret the rest of
            -- the URL, and then we prepend an action for the part we
            -- interpreted.
            ( ShowExample Example1 ) :: List.map Example1Action ( Example1.location2action rest )
        
        "example-2" :: rest ->
            ( ShowExample Example2 ) :: List.map Example2Action ( Example2.location2action rest )

        "example-3" :: rest ->
            ( ShowExample Example3 ) :: List.map Example3Action ( Example3.location2action rest )

        "example-4" :: rest ->
            ( ShowExample Example4 ) :: List.map Example4Action ( Example4.location2action rest )

        "example-5" :: rest ->
            ( ShowExample Example5 ) :: List.map Example5Action ( Example5.location2action rest )

        "example-6" :: rest ->
            ( ShowExample Example6 ) :: List.map Example6Action ( Example6.location2action rest )

        "example-7" :: rest ->
            ( ShowExample Example7 ) :: List.map Example7Action ( Example7.location2action rest )

        "example-8" :: rest ->
            ( ShowExample Example8 ) :: List.map Example8Action ( Example8.location2action rest )

        _ ->
            -- Normally, you'd want to show an error of some kind here.
            -- But, for the moment, I'll just default to example1
            [ ShowExample Example1 ]
