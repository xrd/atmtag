
AtmTag: a fun little AngularJS/Rails application for searching for the most inexpensive and closest ATM

Hightlights:
* Jasmine testing
* Uses Google Places API
* Testacular
* AngularJS 1.1
* Rails asset pipeline (not sure if this works in production/minimized)
* Bootstrap

To run JS tests:

* Start guard to regenerate JS files from coffeescript
  * bundle exec guard
* Start testacular
  * testacular config/testacular.conf.js start --auto-watch --log-level debug
* Open a browser on localhost:8085
* Make code changes in either spec/coffee/*.coffee (spec files) or in the app/assets/javascript/*.coffee files


