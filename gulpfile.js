// Include gulp
var gulp = require('gulp');

// Include Our Plugins
// Load plugins
var $ = require('gulp-load-plugins')({camelize: true});


gulp.task('lint', function() {
    gulp.src('./js/*.js')
        .pipe($.jshint())
        .pipe($.jshint.reporter('default'));
});


gulp.task('sass', function() {
    gulp.src('./scss/*.scss')
        .pipe($.sass({includePaths: ['bower_components/foundation/scss']}))
        .pipe(gulp.dest('./css'))
        .pipe($.connect.reload());
});


// Concatenate & Minify JS
gulp.task('scripts', function() {
    gulp.src('./js/*.js')
        .pipe($.concat('all.js'))
        // .pipe(gulp.dest('./dist'))
        // .pipe($.rename('all.min.js'))
        // .pipe($.uglify())
        // .pipe(gulp.dest('./dist'))
        .pipe($.connect.reload());
});


// Connect Server
gulp.task('connect', $.connect.server({
    root: __dirname,
    port: 9000,
    livereload: true
}));

// Watch
gulp.task('watch', ['connect', 'lint', 'sass', 'scripts'], function () {
    // Watch for changes in `app` folder
    gulp.watch([
        './*.html',
        './scss/**/*.scss',
        './js/**/*.js'
    ], $.connect.reload);

    // Watch .scss files
    gulp.watch('./scss/*.scss', ['sass']);

    // Watch .js files
    gulp.watch('./js/*.js', ['lint', 'scripts']);

});

// Default Task
gulp.task('default', ['lint', 'sass', 'scripts']);