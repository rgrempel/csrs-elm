# Some notes on the Elm code

Here are a few notes on the Elm code. Note that the port to Elm is a
work-in-progress, so there are a variety of things which are unimplemented at
this point, or don't work quite right. But, if you're interested in building
the app to play with, there are [instructions](/README.md).

## Organization

I have organized the Elm modules in a somewhat non-idiomatic way.  For
instance, instead of having a `Validation.elm` file with some supporting files
in a Validation folder, I put the Validation.elm file itself in the Validation
folder. This leads to some redundancy in the module name (e.g. `import
Validation.Validation` instead of `import Validation`. However, I like have the
whole module inside a folder for a variety of reasons, so I do it that way.

## Cyclic Dependencies

On my first try, I was beset with cyclic module dependencies.  To avoid
them, I eventually adopted two principles which work out pretty well.

* Lower-level modules should mostly ask for what they need in their function
  signatures, and let the call-site (in the higher-level modules) provide it.

* Where lower-level modules really need to know something about the
  higher-level module, try to limit that knowledge to types, and possibly some
  very limited functions.

So, I often have a ModuleNameTypes.elm module as a kind of 'header' file that
can be referenced from lower-level modules, while the 'implementation' module
should not be referenced from lower-level modules.

If you implemented principle #1 completely, you probably wouldn't need
principle #2 at all. But, sometimes principle #1 is a bit awkward.

## How many signals

A somewhat related question is how many signals to use in the app.  At one
extreme, every text box that could ever appear in the app could be its own
signal -- it is, after all, a value that changes over time. However, this is
probably impractical (I say 'probably' because I haven't tried it). You could
conceivably end up with hundreds, or even thousands, of signals -- and they
can't be created dynamically, since the signal graph can't change. This
probably is impratical performance-wise, though it would be interesting if I
were wrong about that.

What I do instead is create a single signal for the UI, and then use the
'forwardTo' mechanism to supply addresses to lower-level modules that they can
use to send messages. I also create a signal for each of the 'service-oriented'
modules, so that they can be addressed directly.

There actually is some logic to this division, in this sense.  A UI module
could theoretically appear in multiple contexts in the UI -- I don't have a
case of that yet, but will eventually.  So, you really do need to 'address' it
through its parents, not through a single mailbox of its own. However, the
service-oriented modules are true singletons, so they may as well have their
own mailbox.

## Signal Graph

I found that it was useful to diagram the signal graph once it got a little
complicated, so here it is. The dotted lines indicate cases where I've used
`passiveMap2` from `Signal.Extra`.

![Signal graph](https://cdn.rawgit.com/rgrempel/csrs-elm/master/src/main/elm/signals.svg)

## Routing

One of the things that probably could use some explanation is the routing
and path stuff on the left side of the signal graph. This is essentially
for dealing with the browser history. There are two related operations
involved:

* Making changes to the location
* Reacting to changes in the location

### Making changes to the location

As the user does things in the app, you may wish to make changes to the URL
(well, the hash part, anyway) in order to represent the state of the UI. 
This makes it possible for the forward / back buttons to do something
useful, and also makes certain states of the app bookmarkable to a degree.

One of the things that I realized is that deciding whether to make a change
to the location actually depends on the delta between two models, rather
than just the new model alone. For instance, when you first arrive on
a 'virtual page', one might want to use a `setPath` operation to change
the path. Then, when typing in a search form, one might want to use
`replacePath`. In order to distinguish the cases, one really needs to know
both the current model and the previous model.

It took me a while to figure out how to accomplish this, but finally I 
realized that it was entirely straightforward -- one could simply use `foldp`
to construct a `Signal (Model, Model)` -- that is, a signal of the current
model and previous model. This is actually what I like most about Elm in
the end -- so often, the way to accomplish something is just to say what
you mean.

Note that the function which calculates whether to change the location
(`delta2path`) also gets access to the current location. However, using
`passiveMap2`, changes to the current location don't make `delta2path`
recalculate -- which is part of the effort to cut down on the possible
loop here (that is, we're both making changes to the location and reacting
to changes to the location, so we need to avoid an infinite loop).

### Reacting to changes in the location

In another effort to avoid the infinite loop, the function which reacts
to changes in the location bar gets connected to the last `PathAction`
we took -- that is, the last change which we made to the location bar.
That way, it has a chance to determine that the change we're seeing is
one which we made ourselves, so we shouldn't react to it.

## The Elm Architecture

As you can see from the signal graph, the app follows The Elm Architecture to a
degree, but deviates in certain respects. Here's a quick summary of the
deviations.

### A separate function for reactions

In order to allow for actions that generate tasks (instead of just model changes),
I have a `reaction` function that computes a possible Task for each action.

### The Components / Focus concept

I have divided the modules which make up the app into two kinds:

* Components, in the Components directory, which deal with something I'm calling Focus
  -- which is essentially 'What virtual page am I looking at now, and what ephemeral
  data does it need' (where 'ephemeral' means data which can be thrown away once we're
  on a different virtual page).

* Services, which are not UI-focused, but instead focused on more permanent data
  and communication with the server.

As noted above, the app dispatches to component modules through a single mailbox
and `forwardTo`, whereas service modules each get their own mailbox.

The Components.FocusTypes module defines a FocusModel which is an ADT with tags
for the various component types. So, each Component can define what 'local
data' (Focus) it needs to keep track of on its 'virtual page'. That is, each
Component has its own definition of the data it wants, which I call Focus (at
each level). And, each Component has a list of actions it can perform.

Then, once you get to a particular component, the key functions have these signatures:

```elm
{-| Given a part of the location hash, compute whether we should react to it. -}
route : List String -> Maybe Action

{-| Given the previous focus (if it was ours) and the current focus, compute
    whether we ought to make a change to the location -}
path : Maybe Focus -> Focus -> Maybe PathAction

{-| Given an address to send our actions to, and the current action, compute
    whether a task should be executed in reaction. -}
reaction : Address Action -> Action -> Maybe (Task () ())

{-| Given an action and possibly a focus (if we had the focus already),
    compute the new Focus -}
update : Action -> Maybe Focus -> Maybe Focus

{-| Given an address, the whole model, and our focus, produce the HTML -}
view : Address Action -> Model -> Focus -> Html

{-| Given an address, the whole model, and the focus (if we are being
    focused on) produce HTML for the menu. -}
menu : Address Action -> Model -> Maybe Focus -> Html
```

The `route` and `path` functions implement the location changes and reactions.

The `reaction` function computes a possible `Task` to execute for each `Action`.
One often sees this handled in the `update` function instead -- for instance,
by having `update` return a tuple of `(Model, Task)` or something like that.
Those seem like two different jobs to me, so I put them in two different functions.

Note that the `reaction` function only knows about the `Action` -- it does not have
access to the model, or even the focus! This means that there needs to be enough
data in the `Action` itself to compute the necessary reaction. So far, this hasn't
been a problem. It would not be hard to give the `reaction` function read-only
access to the model and/or focus, if that turns out to be needed.

The `update` function is a little curious in that each module only gets access
to the Focus that it defines -- that is, only to its own data. It does not
get the whole model. If the module wants to do something that would change
other parts of the model, then it has to do so via `reaction` -- that is, by
generating a `Task`, typically a `Task` defined by a service module.

However, in the `view` function, the module gets both the whole model and
its own focus. Now, the module's own focus is actually part of the whole model,
of course. However, it is supplied separately anyway, so that the module doesn't
have to know **where** in the whole model to find its own data. As noted above,
this is needed, for instance, in cases where the module might be represented
on the page more than once, or possibly with different parent components.

The `menu` function is essentially equivalent to the `view` function, except
that the module is only being asked to generate HTML for a menu (thus, it may
or may not currently have the focus).

# Other Points of Interest

There are a few other things which could be points of interest.

## How to do localization

I have essentially used ordinary Elm functions to provide translation of the
entire UI into English, French and Latin. (Note that the French and Latin is
not necessarily very good yet). See the modules under Language, and the various
individual ...Text.elm modules.

One nice feature of doing it this way is that the translations can be checked
by the compiler -- that is, I can't ask for a translation that isn't defined.

## How to do routing based on location

See the Route/RouteService.elm module, and the discussion above about location.

## How to validate forms

I have a start on this in the Validation modules, and the various forms that
use them. It's a little primitive so far -- I've only implemented what I needed
as I port the app.


