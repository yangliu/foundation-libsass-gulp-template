# Include gulp and plugins
gulp       = require 'gulp'
gutil      = require 'gulp-util'
jade       = require 'gulp-jade'
minifyHTML = require 'gulp-minify-html'
sass       = require 'gulp-sass'
cssmin     = require 'gulp-cssmin'
coffee     = require 'gulp-coffee'
uglify     = require 'gulp-uglify'
header     = require 'gulp-header'
rename     = require 'gulp-rename'
concat     = require 'gulp-concat'
connect    = require 'gulp-connect'
jshint     = require 'gulp-jshint'
coffeelint = require 'gulp-coffeelint'
tempus     = require 'tempusjs'
fs         = require 'fs'
pkg        = require './package.json'

readJSONSync = (json_file) ->
  return JSON.parse fs.readFileSync json_file

gulp.task 'lint', ->
  gulp.src './src/js/*.js'
    .pipe jshint()
    .pipe jshint.reporter 'default'

  gulp.src '.src/coffee/*.coffee'
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'sass', ->
  gulp.src './src/sass/*.scss'
    .pipe sass
      includePaths: ['bower_components/foundation/scss']
    .pipe cssmin()
    .pipe gulp.dest './build/css'
    .pipe connect.reload()

gulp.task 'coffee', ->
  gulp.src './src/coffee/*.coffee'
    .pipe coffee()
    .pipe gulp.dest './src/.compiled_js'

gulp.task 'scripts', ['coffee'], ->
  gulp.src ['./src/js/*.js', './src/.compiled_js/*.js']
    .pipe concat 'app.js'
    .pipe uglify()
    .pipe gulp.dest './build/js'
    .pipe connect.reload()

gulp.task 'jade', ->
  jade_data = {}
  # jade_data =
  #   members: readJSONSync './src/data/members.json'
  #   featured_articles: readJSONSync './src/data/featured.json'
  build_no = tempus().format '%Y%m%d'
  banner = fs.readFileSync 'src/header'
  banner += "\
    <!--\n\
      Something write here\n\
      Version: #{pkg.version} build #{build_no}\n\
    -->\n\
    "
  gulp.src './src/jade/*.jade'
    .pipe jade()
      # data: jade_data
    .pipe minifyHTML()
    .pipe header banner
    .pipe gulp.dest './build'
    .pipe connect.reload()

gulp.task 'vendor', ->
  # copy vendor files
  gulp.src 'bower_components/foundation/js/foundation/*.js'
    .pipe gulp.dest './build/js/vendor/foundation/foundation'
  gulp.src 'bower_components/foundation/js/vendor/*.js'
    .pipe gulp.dest './build/js/vendor'
  # combine jquery and foundation together
  gulp.src ['bower_components/foundation/js/vendor/jquery.js', 'bower_components/foundation/js/foundation.min.js']
    .pipe concat('jquery-foundation.js')
    .pipe gulp.dest './build/js/vendor/foundation'


gulp.task 'connect', connect.server
  root: './build'
  port: 8000
  livereload:
    port: 35729

gulp.task 'watch', ['connect', 'lint', 'sass', 'scripts', 'jade', 'vendor'], ->
  gulp.watch ['src/jade/*.jade'], ['jade']
  gulp.watch ['src/coffee/*.coffee', 'src/js/*.js'], ['lint', 'scripts']
  gulp.watch ['src/sass/*.sass'], ['sass']
  gulp.watch ['bower_components/foundation/js/foundation.min.js'], ['vendor']
  gulp.watch ['bower_components/foundation/js/foundation/*.js'], ['vendor']
  gulp.watch ['bower_components/foundation/js/vendor/*.js'], ['vendor']


gulp.task 'default', ['lint', 'vendor', 'sass', 'scripts', 'jade']
