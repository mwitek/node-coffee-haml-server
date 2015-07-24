"use strict"

# Load plugins
gulp = require("gulp")
open = require('gulp-open')
path = require("path")
sass = require('gulp-sass')
haml = require('gulp-haml-coffee')
jquery = require('gulp-jquery')
livereload = require('gulp-livereload')
$ = require("gulp-load-plugins")()
sourcemaps = require("gulp-sourcemaps")
connect = require('gulp-connect')
options = {}

# Scripts
gulp.task "scripts", ->
  gulp.src("app/scripts/application.coffee",
    read: false
  )
    .pipe($.browserify(
      insertGlobals: true
      extensions: [
        ".coffee"
      ]
      transform: [
        "coffeeify"
        "reactify"
        "debowerify"
      ]
      shim:
        'waypoints':
          path: 'app/bower_components/waypoints/lib/jquery.waypoints.js'
          exports: null
        'eventEmitter':
          path: 'app/bower_components/eventEmitter/EventEmitter.js'
          exports: null
    ))
    .on("error", handleError)
    .pipe($.rename("application.js"))
    .pipe(gulp.dest("dist/scripts"))
    .pipe(connect.reload())
    .pipe($.size())

options.sass =
  errLogToConsole: true
  sourceComments: 'normal'
  sourceMap: 'sass'

gulp.task "sass", ->
  gulp
    .src("./app/stylesheets/application.scss")
    .pipe(sass(options.sass))
    .pipe(gulp.dest("dist/stylesheets"))
    .pipe(connect.reload())
    .on "error", $.util.log
  return

gulp.task "fonts", ->
  $.bowerFiles()
    .pipe($.filter("**/*.{eot,svg,ttf,woff}"))
    .pipe($.flatten())
    .pipe(gulp.dest("dist/fonts"))
    .pipe $.size()

gulp.task "assets", ->
  gulp
    .src("app/{api,stylesheets}/**/*.{less,sass,scss,css,json,html,haml,js}")
    .pipe gulp.dest("dist/")

gulp.task "html", ->
  gulp
    .src("app/*.html")
    .pipe($.useref())
    .pipe(gulp.dest("dist"))
    .pipe(livereload())
    .pipe($.size())
    .pipe(connect.reload())
    .on "error", $.util.log

gulp.task "haml", ->
  gulp
    .src("app/**/*.haml")
    .pipe(haml())
    .pipe(gulp.dest("dist"))
    .pipe(connect.reload())
    .on "error", $.util.log
  return

gulp.task 'jquery', ->
  jquery.src(
    release: 2
  ).pipe gulp.dest('dist/scripts/')

gulp.task "images", ->
  gulp
    .src("app/images/**/*")
    .pipe(gulp.dest("dist/images"))
    .pipe($.size())
    .pipe(connect.reload())

gulp.task "clean", ->
  gulp.src("dist",
    read: false
  ).pipe $.clean()

gulp.task "styles", ["sass"]

gulp.task "bundle", [
  "assets"
  "scripts"
  "styles"
  "bower"
], $.bundle("./app/*.html")

gulp.task "build", [
  "html"
  "haml"
  "bundle"
  "images"
  "jquery"
]

gulp.task "default", [ "open", "connect","watch"], ->
  gulp.start "build"
  return

# Connect
gulp.task "connect", connect.server(
  root: ["dist"]
  port: 5000
  livereload: true
)

gulp.task 'open', ->
  gulp.src(__filename)
  .pipe(open({uri: 'http://localhost:5000'}))

# Bower helper
gulp.task "bower", ->
  gulp.src("app/bower_components/**/*.{js,css}",
    base: "app/bower_components"
  ).pipe gulp.dest("dist/bower_components/")
  return

gulp.task "json", ->
  gulp.src("app/scripts/json/**/*.json",
    base: "app/scripts"
  ).pipe gulp.dest("dist/scripts/")
  return

# Watch
gulp.task "watch", [
  "images"
  "assets"
  "html"
  "haml"
  "bundle"
  "connect"
], ->
  
  # Watch .html files
  gulp.watch "app/*.html", ["html"]
  gulp.watch "app/**/*.haml", ["haml"]
  
  # Watch .coffeescript files
  gulp.watch "app/scripts/**/*.coffee", ["scripts"]
  gulp.watch "app/stylesheets/**/*.css", ["assets"]
  gulp.watch "app/stylesheets/**/*.sass", ["sass"]
  gulp.watch "app/stylesheets/**/*.scss", ["sass"]
  
  # Watch .js files
  gulp.watch "app/scripts/**/*.js", ["scripts"]
  
  # Watch image files
  gulp.watch "app/images/**/*", ["images"]
  return

handleError = (error) ->
  console.warn error
  @emit "end"
