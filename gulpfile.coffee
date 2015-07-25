"use strict"

class GulpBuilder
  APP_ASSETS = ["html","haml","scripts","css","bower","images"]
  
  constructor: ->
    @gulp = require("gulp")
    @sass = require('gulp-sass')
    @haml = require('gulp-haml-coffee')
    @livereload = require('gulp-livereload')
    @browserify = require("gulp-browserify")
    @rename = require("gulp-rename")
    @size = require("gulp-size")
    @util = require("gulp-util")
    @bowerFiles = require("gulp-bower-files")
    @filter = require("gulp-filter")
    @flatten = require("gulp-flatten")
    @useref = require("gulp-useref")
    @server = require( 'gulp-server-livereload')
    @options = {}
    
    @gulp.task "bower", @compileBowerComponents
    @gulp.task "scripts", @compileJavascript
    @gulp.task "json", @compileJson
    @gulp.task "css", @compileCSS
    @gulp.task "fonts", @compileFonts
    @gulp.task "html", @compileHTML
    @gulp.task "haml", @compileHAML
    @gulp.task "images", @compileImages
    @gulp.task "connect", @connectToServer
    @gulp.task "watch", @watchGulpTask
    @gulp.task "build", APP_ASSETS
    
    @gulp.task "default", ["build"], =>
      @gulp.start('connect')
      @gulp.start('watch')
    
  compileJavascript: =>
    return @gulp.src("app/scripts/application.coffee", read: false)
      .pipe(@browserify(
        insertGlobals: true
        extensions: [
          ".coffee"
        ]
        transform: [
          "coffeeify"
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
      .on("error", @handleError)
      .pipe(@rename("application.js"))
      .pipe(@gulp.dest("dist/scripts"))
      .pipe(@size())
      
  compileCSS: =>
    @options.sass =
      errLogToConsole: true
      sourceComments: 'normal'
      sourceMap: 'sass'
    return @gulp
      .src("./app/stylesheets/application.{scss,sass}")
      .pipe(@sass(@options.sass))
      .pipe(@rename("application.css"))
      .pipe(@gulp.dest("dist/stylesheets"))
      .on "error", @util.log

  compileFonts: =>
    @bowerFiles()
      .pipe(@filter("**/*.{eot,svg,ttf,woff}"))
      .pipe(@flatten())
      .pipe(@gulp.dest("dist/fonts"))
      .pipe @size()
  
  compileHTML: =>
    return @gulp
      .src("app/*.html")
      .pipe(@useref())
      .pipe(@gulp.dest("dist"))
      .pipe(@size())
      .on "error", @util.log
  
  compileHAML: =>
    return @gulp
      .src("app/**/*.haml")
      .pipe(@haml())
      .pipe(@gulp.dest("dist"))
      .on "error", @util.log
  
  compileImages: =>
    return @gulp
      .src("app/images/**/*")
      .pipe(@gulp.dest("dist/images"))
      .pipe(@size())
  
  connectToServer: =>
    return @gulp.src('dist')
      .pipe @server
        livereload: true
        open: true
        port: 5000

  compileBowerComponents: =>
    return @gulp
      .src("app/bower_components/**/*.{js,css}", base: "app/bower_components")
      .pipe(@gulp.dest("dist/bower_components/"))
  
  compileJson: =>
    @gulp
      .src("app/scripts/json/**/*.json", base: "app/scripts")
      .pipe(@gulp.dest("dist/scripts/"))

  watchGulpTask: =>
    @gulp.watch "app/*.html", ["html"]
    @gulp.watch "app/**/*.haml", ["haml"]
    @gulp.watch "app/scripts/**/*.coffee", ["scripts"]
    @gulp.watch "app/stylesheets/**/*.sass", ["css"]
    @gulp.watch "app/stylesheets/**/*.scss", ["css"]
    @gulp.watch "app/scripts/**/*.js", ["scripts"]
    @gulp.watch "app/images/**/*", ["images"]
    return

  handleError: (error) ->
    console.warn error
    @emit "end"

new GulpBuilder()