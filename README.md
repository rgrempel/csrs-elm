[![Build Status](https://travis-ci.org/rgrempel/csrs-elm.svg)](https://travis-ci.org/rgrempel/csrs-elm)

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

## Points of Interest

### Elm

As far as points of interest go, there are a variety of things on the Elm side
that could be of interest to Elm programmers -- see
[src/main/elm](src/main/elm) for the code.

### Java

For the Java side, some of the stuff that I'm doing with Specifications could
be interesting -- see
[src/main/java/com/fulliautomatix/csrs/specification](src/main/java/com/fulliautomatix/csrs/specification)
for the source. Essentially, I'm using specifications and their JSON representations as
a method to transmit queries from the client to the server. This is an area
that doesn't really have an obvious solution, though of course there are a
variety of alternatives.

## Building the App

This app is quite project-specific, but I thought it would be nice to make it
buildable by others in case they wanted to play with it (especially the Elm code).
So, here is a step-by-step guide:

* Clone the repository from Github: e.g.

    ```git clone https://github.com/rgrempel/csrs-elm.git```

* Create Postgresql databases and users for the app to use: e.g.

    ```
    createuser csrs
    createdb -O csrs csrs-dev
    createdb -O csrs csrs-test
    ```

* We use the Postgresql 'unaccent' extension, which needs to be installed by
  the superuser. So, you need to do that manually ... e.g.

    ```
    psql -d csrs-dev -c "CREATE EXTENSION unaccent"
    psql -d csrs-test -c "CREATE EXTENSION unaccent"
    ```

* Take a look at [src/main/resources/config](src/main/resources/config) and
  [src/test/resources/config](src/test/resources/config). Copy the \*.template
  files to .yml files, and customize the settings to fit your database settings
  and other settings.

* You'll need to install the [node package manager](https://www.npmjs.com/). Then,
  use it to install some dependencies:

    ```npm install```

* You will need to install [Elm](http://elm-lang.org/). Then, install our
  Elm dependencies:

    ```elm-package install```

* All having gone well, you should now be able to run the tests successfully, e.g.

    ```./gradlew test```

* At this point, you should have a fairly normal Spring Boot / Gradle setup.
  So, for instance, to run the app in-place, you can do the usual:

    ```./gradlew bootRun```

* There are two accounts pre-set: username "admin", password "admin"; and
  username "user", password "user". Of course, you'll want to change those
  passwords if you're going to expose the app ...
