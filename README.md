# CSRS Membership Web Site

This is the code for a membership database that I am working on for the
Canadian Society for Renaissance Studies.

It was originally a JHipster app -- that is, using Spring at the back end and
Angular.js at the front end. However, I did not stick with the JHipster
workflow very long -- just used it as a starting point (for which it was very
useful indeed).

Then, I became aware of the Elm programming language, which is a functional
programming language that compiles to Javascript for the front-end. In order to
learn Elm, I decided to try porting the application to Elm -- I figured I would
abandon the effort when it became clear that Elm couldn't handle what I wanted
to do. So far, that hasn't happened ...

I've also taken a look at Purescript as an Elm altrnative.  In some ways,
Purescript is more sophisticated, since it borrows more of the Haskell functional
goodness (though not slavishly).  However, Elm is somewhat more approachable,
and I haven't really needed any of Purescript's extra sophistication yet.
Plus, Elm is more squarely focused on the 'functional reactive' UI model,
though Purescript does have packages like purescript-halogen which take
similar approaches.

As far as points of interest go, there are a variety of things on the Elm
side that could be of interest to Elm programmers -- see src/main/Elm for
the code.

For the Java side, some of the stuff that I'm doing with Specifications
could be interesting -- see src/main/java/com/fulliautomatix/csrs/specification
for source. Essentially, I'm using specifications and their JSON representations
as a method to transmit queries from the client to the server. This is an
area that doesn't really have an obvious solution, though of course there are
a variety of alternatives.

Note that the port to Elm is a work-in-progress, so there are a variety
of things which are unimplemented at this point.
