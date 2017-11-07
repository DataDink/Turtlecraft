var gulp = require('gulp');
var concat = require('gulp-concat');
var minify = require('gulp-luaminify');
var insert = require('gulp-insert');
var Pastebin = require('./pastebin');
var fs = require('fs');

// Creates an object-array of arguments passed to node/gulp
var args = Array.from(process.argv).slice(3);
args.forEach((a, i) => { if (/^--\w+/gi.exec(a)) { args[a.replace(/^--/gi, '')] = args[i+1]; }});

// Loads the requested (or default) config
var env = args.env || 'debug';
var config = require('./src/configs/' + env + '.json');
config.build = (new Date()).valueOf().toString();
config.env = env;
var cfgjson = JSON.stringify(JSON.stringify(config));

/*******************************GULP COMMANDS*******************************/

gulp.task('build', complete => {
  var stream = gulp.src([
    'src/init.lua',
    'src/turtlecraft/**/*.lua',
    'src/bootstrap.lua'
  ]).pipe(insert.append('\nz99999();')) // Ambiguous errors fix
    .pipe(concat('turtlecraft.lua'))
    .pipe(insert.prepend('local cfgjson = ' + cfgjson + ';\n', {src: true}));

  if (config.minify) { stream.pipe(minify()) }

  stream.pipe(insert.transform(v => {
          return v.replace(/\s*;?\s*z99999\(\)\s*\;?\s*/gi, ';\n');
        }))
        .pipe(gulp.dest('dist'));

  return stream;
});

gulp.task('upload', complete => {
  var turtlecraft = fs.readFileSync('dist/turtlecraft.lua', 'utf8');

  authenticate().then(credentials => {
    new Pastebin(credentials.key)
    .login(credentials.username, credentials.password)
      .then((data) => {
        console.log(data);
      }).catch(e => console.error('Failed to authenticate user: ', e));
  }).catch(e => console.error('Failed to authenticate user: ', e));
});

function authenticate() {
  return new Promise((success, error) => {
    var credentials = fs.existsSync('./pastebin.json') ? require('./pastebin.json') : {};
    var questions = {};
    if (!('key' in credentials)) { questions.devkey = { required: true }; }
    if (!('username' in credentials)) { questions.username = { required: true }; }
    if (!('password' in credentials)) { questions.password = { required: true, hidden: true }; }
    require('prompt').get({properties: questions}, (e, answers) => {
      if (e) { return error(e); }
      for (m in answers) { credentials[m] = answers[m]; }
      success(credentials);
    });
  });
}
