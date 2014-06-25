gulp    = require 'gulp'
nodemon = require 'nodemon'

pkg     = require './package'

gulp.task 'watch', (done) ->
  nodemon
    script: pkg.main
    ext: 'coffee js json'
  .on 'start', ->
    console.log 'nodemon started'
  .on 'exit', (err) ->
    console.log 'nodemon exited'
  .on 'crash', (err) ->
    console.log 'nodemon crashed'
