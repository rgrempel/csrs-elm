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

As far as points of interest go, there are a variety of things on the Elm side
that could be of interest to Elm programmers -- see
[src/main/elm](src/main/elm) for the code.

For the Java side, some of the stuff that I'm doing with Specifications could
be interesting -- see src/main/java/com/fulliautomatix/csrs/specification for
source. Essentially, I'm using specifications and their JSON representations as
a method to transmit queries from the client to the server. This is an area
that doesn't really have an obvious solution, though of course there are a
variety of alternatives.

Note that there are some missing files and other problems with the build process
such that I don't really expect people to be able to build the app. Instead, it's
here mainly to illustrate some techniques, especially in the Elm code. At some
point, I may break various things out into separate packages that are more easily
used by others.
