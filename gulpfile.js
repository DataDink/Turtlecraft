var gulp = require('gulp');
var concat = require('gulp-concat');
var minify = require('gulp-luaminify');
var insert = require('gulp-insert');

// Creates an object-array of arguments passed to node/gulp
var args = Array.from(process.argv).slice(3);
args.forEach((a, i) => { if (/^--\w+/gi.exec(a)) { args[a.replace(/^--/gi, '')] = args[i+1]; }});

// Loads the requested (or default) config
var env = args.env || 'default';
var config = require('./src/configs/' + env + '.json');
config.build = (new Date()).valueOf().toString();
var cfgjson = JSON.stringify(JSON.stringify(config));

/*******************************GULP COMMANDS*******************************/
gulp.task('default', ['build', 'deploy']);

gulp.task('build', complete => {
  var stream = gulp.src([
    'src/init.lua',
    'src/turtlecraft/**/*.lua',
    'src/bootstrap.lua'
  ]);

  if (config.minify) {
    stream
      .pipe(minify())
      .pipe(insert.append(';'));
  }

  stream
  .pipe(concat('turtlecraft.lua'))
  .pipe(insert.prepend('local cfgjson = ' + cfgjson + ';\n', {src: true}))
  .pipe(gulp.dest('dist'));

  return stream;
});

gulp.task('deploy', complete => {
  var fs = require('fs');
  var pastebin = require('better-pastebin');
  var turtlecraft = fs.readFileSync('dist/turtlecraft.lua', 'utf8');
  var credentials = fs.existsSync('./pastebin.json') ? require('./pastebin.json') : {};

  function upload() {
    pastebin.setDevKey(credentials.key);
    pastebin.login(credentials.username, credentials.password, (s, e) => {
      if (!s) { throw e; }
      pastebin.edit(config.pastebin, {
        contents: turtlecraft,
        expires: 'N',
        format: 'text',
        privacy: 1,
        name: 'turtlecraft v' + config.version
      }, (s, e) => {
        if (!s) { throw e; }
        console.log('Deployed to: ' + config.pastebin);
        complete();
      });
    });
  }

  if (args.pbapikey) { credentials.key = args.pbapikey; }
  if (args.pbusername) { credentials.username = args.pbusername; }
  if (args.pbpassword) { credentials.password = args.pbpassword; }
  if (!args.pbusername || !args.pbpassword) {
    require('prompt').get({ properties: {
      username: { required: true },
      password: { required: true, hidden: true }
    }}, (e, input) => {
      if (e) { throw 'Unable to resolve pastebin credentials'; }
      credentials.username = input.username;
      credentials.password = input.password;
      upload();
    });
  } else {
      upload();
  }
});
