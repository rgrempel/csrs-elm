module RouteHash
    ( HashUpdate, set, replace, map, extract
    , Config, defaultPrefix, start
    ) where


{-| Module docs

@doc HashUpdate, set, replace, none, map, extract
@doc Config, defaultPrefix, start
-}


import String exposing (uncons, split)
import Http exposing (uriDecode, uriEncode)
import Signal exposing (Signal, Address, send, merge)
import Signal.Extra exposing (passiveMap2)
import Task exposing (Task)
import History


{-| An opaque type which represents an update to the hash portion of the
browser's location.

Manipulated via set, replace, update or extract.
-}
type HashUpdate 
    = SetPath (List String)
    | ReplacePath (List String)


{-| Returns a HashUpdate that will update the browser's location, creating
a new history entry.
-}
set : List String -> HashUpdate
set = SetPath


{-| Returns a HashUpdate that will update the browser's location, without
creating a new history entry.
-}
replace : List String -> HashUpdate
replace = ReplacePath


{-| Applies the supplied function to the HashUpdate. -}
apply : (List String -> List String) -> HashUpdate -> HashUpdate
apply func update =
    case update of
        SetPath list ->
            SetPath (func list)

        ReplacePath list ->
            ReplacePath (func list)


{-| Applies the supplied function to the HashUpdate. -}
map : (List String -> List String) -> Maybe HashUpdate -> Maybe HashUpdate
map func update =
    Maybe.map (apply func) update
    

{-| Extracts the List String from the HashUpdate. -}
extract : HashUpdate -> List String
extract action =
    case action of
        SetPath list ->
            list

        ReplacePath list ->
            list


{-| Represents the configuration necessary to use this module.

* `prefix` is the initial characters that should be stripped from
   the hash (if present) when reacting to location changes, and
   added to the hash when generating location changes. Normally,
   you'll likely want to use `defaultPrefix`, which is "#!/"

* `models` is your signal of models. This is used so that we can
  react to changes in the model, possibly generating a new location.
  If you're using start-app, then this is the `app.models` that is
  returned when you call `StartApp.start`.

* `initialModel` is your initial model. It is used when processing
  the first model change that your app generates. If you're using
  start-app, then this is the `initialModel` that you supply to
  `StartApp.start`.

* `delta2update` is a function which takes two arguments and possibly
  generates a location update. The first argument is the previous model.
  The second argument is the current model.

  The reason you are provided with both the previous and current models
  is that sometimes the nature of the location update depends on the
  difference between the two, not just on the latest model. For instance,
  if the user is typing in a form, you might want to use `replace` rather
  than `set`. Of course, in cases where you only need to consult the
  current model, you can ignore the first parameter.

  This module will process the `List String` in the update in the following
  way. It will:

  * uriEncode the strings
  * join them with "/"
  * add the `prefix` to the beginning

  In a modular application, you may well want to use `map` after dispatching
  to a lower level.

  Note that this module will automatically detect cases where you return
  a HashUpdate which would set the same location that is already set, and
  do nothing. Thus, you don't need to try to detect that yourself.

  The content of the individual strings is up to you ... essentially it
  should be something that your `location2action` function can deal with.

* `location2action` is a function which takes a `List String` and returns
  an action. The argument is a decoded version of the hash portion of
  the location. First, the `prefix` is stripped from the hash, and then
  the result is converted to a `List` by using '/' as a delimiter. Note
  that the individual `String` values have already been uriDecoded for you.
-} 
type alias Config model action =
    { prefix : String
    , models : Signal model
    , initialModel : model
    , delta2update : model -> model -> Maybe HashUpdate
    , address : Address action
    , location2action : List String -> Maybe action
    }


{-| The defaultPrefix that you will most often want to supply as the
`prefix` in your `Config`. It is equal to "#!/".
-}
defaultPrefix : String
defaultPrefix = "#!/"


{-| Call this function once with your configuration, and then use
the returned value as part of your app setup.

See `Config` for the documentation of the parameter you need to supply.
-}
start : Config model action -> Signal (Task () ())
start config =
    let
        {-  A signal of the model changes ... first element in the tuple is
            previous, second is current.
        
            changes : Signal (model, model)
        -}
        changes =
            deltas config.initialModel config.models


        {-  A signal of the hash in the location bar, but normalized to a List
            String.
            
            locations : Signal (List String)
        -}
        locations = 
            Signal.map (hash2list config.prefix) History.hash


        {-  Given each change, what update would we make to the location?
            
            updates : Signal (Maybe HashUpdate)
        -}
        updates =
            Signal.map (uncurry config.delta2update) changes
    

        {-  A signal of the updates, filtering out those which wouldn't
            actually change the current location.
            
            actualUpdates : Signal HashUpdate
        -}
        actualUpdates =
            -- Note that we use passivMap2 so that the signal only updates when
            -- the model changes. That is, we're consulting the location, not
            -- firing when the location changes. This helps avoid a situation
            -- where we create an infinite loop ... that is, where the location
            -- chnage triggers a model change, which triggers a location
            -- change.  The other thing which helps avoid this is that we
            -- check, via dropIfCurrent, whether we're **actually** changing
            -- the location.
            passiveMap2 dropIfCurrent updates locations


        {-  A Signal of Tasks that actually update the location.
            
            updateTasks : Signal (Task () ())
        -}
        updateTasks =
            Signal.map update2task actualUpdates

        
        {-  Converts an a HashUpdate to a Task.

            update2task : Maybe HashUpdate -> Task () ()
        -}
        update2task update =
            case update of
                Just (SetPath list) ->
                    History.setPath <|
                        list2hash config.prefix list

                Just (ReplacePath list) ->
                    History.replacePath <|
                        list2hash config.prefix list
 
                Nothing ->
                    Task.succeed ()


        -- actions : Signal (Maybe action)
        actions =
            passiveMap2 route locations actualUpdates


        -- route : List String -> Maybe HashUpdate -> Maybe action
        route location update =
            case update of
                Just (SetPath list) ->
                    if list == location
                        then Nothing
                        else config.location2action location

                Just (ReplacePath list) ->
                    if list == location
                        then Nothing
                        else config.location2action location

                Nothing ->
                    config.location2action location

        actionTasks =
            Signal.filterMap action2task (Task.succeed ()) actions

        
        action2task action =
            Maybe.map (Signal.send config.address) action

    in
        Signal.merge actionTasks updateTasks


{-|  Tests whether an update would actually change our location. -}
dropIfCurrent : Maybe HashUpdate -> List String -> Maybe HashUpdate
dropIfCurrent update current =
    case update of
        Just (SetPath list) ->
            if list == current
                then Nothing
                else update

        Just (ReplacePath list) ->
            if list == current
                then Nothing
                else update

        Nothing ->
            Nothing


{-| Remove the character from the string if it is the first character -}
removeInitial : Char -> String -> String
removeInitial initial original =
    case uncons original of
        Just (first, rest) ->
            if first == initial
                then rest
                else original
        
        _ ->
            original


{-| Remove initial characters from the string, as many as there are.

So, for "#!/", remove # if is first, then ! if it is next, etc.
-}
removeInitialSequence : String -> String -> String
removeInitialSequence initial original =
    String.foldl removeInitial original initial


{-| Takes a string from the location's hash, and normalize it to a list of strings
that were separated by a slash. -}
hash2list : String -> String -> List String
hash2list prefix =
    removeInitialSequence prefix >> split "/" >> List.map uriDecode


{-| The opposite of normalizeHash ... takes a list and turns it into a hash -}
list2hash : String -> List String -> String
list2hash prefix list =
    prefix ++ String.join "/" (List.map uriEncode list)
        

{-| A signal of changes to the model.

The tuple has the previous model first and then the current model.

We use this to calculate possible changes to the location. We need the previous
model because whether to make the change, and whether to make it a "setPath" or
"replacePath", depends on the previous state.  Well, I suppose it could depend
on the previous location, but this seems simpler ... we just assume that the
previous location was propertly set (which seems safe, since this is what is
doing it ...).
-}
deltas : a -> Signal a -> Signal (a, a)
deltas initial signal =
    let
        step model delta = (snd delta, model)

    in
        Signal.foldp step (initial, initial) signal


