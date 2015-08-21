# elm-cookies

This is a Cookies API for the Elm programming language.

## Getting Cookies

You can get the cookies with the `get` task.

```elm
get : Task x (Dict String String) 
```

`get` results in a `Dict` of key -> value pairs which represent the key / value
pairs parsed from Javascript's `document.cookie`. Both keys and values are
uriDecoded for you.

## Setting Cookies

If you don't need to provide special options, then you can just create
a `set` task by supplying the key and value.

```elm
set : String -> String -> Task x ()
```

Both the key and the value will be uriEncoded for you.

If you need to provide options in addition to the key and value, use `setWithOptions`.

```elm
setWithOptions : Options -> String -> String -> Task x ()
```

The options are a record type with the possible options:

```elm
type alias Options =
    { path : Maybe String
    , domain : Maybe String
    , maxAge : Maybe Time
    , expires : Maybe Date 
    , secure : Maybe Bool
    }
```

You can use `defaultOptions` as a starting point, in which all options are set to `Nothing`.

```elm
defaultOptions : Options
```

## Installation

Because elm-cookies uses a 'native' module, it
[requires approval](https://github.com/elm-lang/package.elm-lang.org/issues/48)
before it can be included in the
[Elm package repository](http://package.elm-lang.org/packages). Thus, you cannot
currently install it using `elm-package`.

In the meantime, you can install it and use it via the following steps:

*   Download this respository in one way or another. For instance, you might use:

        git clone https://github.com/rgrempel/elm-cookies.git

    Or, you might use git submodules, if you're adept at that. (I wouldn't suggest
    trying it if you've never heard of them before).

*   Modify your `elm-package.json` to refer to the `src` folder.

    You can choose where you want to put the downloaded code, but wherever that
    is, simply modify your `elm-package.json` file so that it can find the
    `src` folder.  So, the "source-directories" entry in your
    `elm-package.json` file might end up looking like this:

        "source-directories": [
            "src",
            "elm-cookies/src"
        ],

    But, of course, that depends on where you've actually put it.

*   Modify your `elm-package.json` to add elm-http as a dependency, if it's not
    already there. E.g.

        "dependencies": {
            "elm-lang/core": "2.0.0 <= v < 3.0.0",
            "evancz/elm-http": "1.0.0 <= v < 2.0.0",
            ... your other dependencies
        },

*   Modify your `elm-package.json` to indicate that you're using 'native' modules.
    To do this, add the following entry to `elm-package.json`:

        "native-modules": true,

Now, doing this would have several implications which you should be aware of.

*   You would, essentially, be trusting me (or looking to verify for yourself)
    that the code in [Cookies.js](src/Native/Cookies.js) is appropriate code for
    a 'native' module, which would eventually be approved via the approval
    process mentioned above.

*   You would be relying on me to update that code when the mechanism for using
    'native' modules in Elm changes, or when certain other internal details of Elm's
    implementation change. Furthermore, you'd have to check here whenever the Elm
    compiler's version changes, or the Elm core library's version changes, to see
    whether an update is required.

*   If you're using this as part of a module you'd like to publish yourself,
    then you'll now also need approval before becoming available on the Elm
    package repository.

*   If elm-cookies is ever 
    [accepted into the Elm repository](https://github.com/elm-lang/package.elm-lang.org/issues/48),
    then you'll need to undo the steps above and then install it with
    `elm-package` in the usual way.

So, you may or may not really want to do this. But I thought it would be nice to
let you know how.
