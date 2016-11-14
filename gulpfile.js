var gulp = require('gulp');
var concat = require('gulp-concat');
var minify = require('gulp-luaminify');

gulp.task('default', function() {
  return gulp.src([
    'src/application.lua',
    'src/config.lua',
    'src/services/*.lua',
    'src/modules/*.lua',
    'src/bootstrap.lua'
  ])
  .pipe(concat('turtlecraft.lua'))
  .pipe(minify())
  .pipe(gulp.dest('dist'));
});
