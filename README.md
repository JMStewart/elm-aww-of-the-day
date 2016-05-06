# Aww of the Day

This app displays the current top post on the [/r/aww](http://reddit.com/r/aww) subreddit. Enjoy the adorable pictures!

## Building

This project is built in the [Elm](http://elm-lang.org/) language. To get started, first install Elm.

    npm install elm -g
    
Then install the required Elm packages. These are listed in the `elm-package.json`.

    elm package install
    
For development, start the Elm Reactor, navigate to `http://localhost:8000`, and click on `Aww.elm`. 

    elm reactor
    
Finally, build the project for release.

    elm make Aww.elm
