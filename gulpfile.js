var gulp = require('gulp');
var concat = require('gulp-concat');
var minify = require('gulp-luaminify');
var insert = require('gulp-insert');
var https = require('https');

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

gulp.task('deploy', complete => {
  // NOTE: Pastebin is fucked
  // My dev key that previously worked is now returning "invalid dev key"
  // There is no documentation as to what might cause my dev key to be invalid.
  // As far as I can tell my account is in good standing.
  // Also 200 is not an error response btw.
  var fs = require('fs');
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
        name: 'turtlecraft v' + config.version + ' ' + env
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
      uploadPastebin(credentials);
    });
  } else {
      upload();
  }
});

// TODO: Finish this up when pastebin starts working again
function uploadPastebin(credentials, data) {
  pastebin('POST', 'api_login.php', {
    'api_dev_key': credentials.key,
    'a_users_username': credentials.username,
    'a_users_password': credentials.password
  }).then((t, r) => {
    console.log(t, r);
  }).catch((t, r) => {
    console.log(t, r);
  })
}

function pastebin(method, command, data) {
  return new Promise((success, error) => {
    data = formatContent(data);
    var request = https.request({
      hostname: 'pastebin.com',
      path: '/api/' + command,
      method: method,
      header: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(data)
      }
    }, (response) => {
      response.setEncoding('utf8');
      var responseText = '';
      response.on('data', (chunk) => { responseText += chunk; });
      response.on('end', () => {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          success(responseText, response);
        } else {
          error(responseText, response);
        }
      });
    });
    request.on('error', (e) => {
      error(e, request);
    });
    request.write(data, 'utf8', () => {
      request.end();
    });
  });
}

function formatContent(content) {
  if (typeof(content) === 'string') { return content; }
  if (typeof(content) !== 'object') { return ''; }
  var parts = [];
  for (var member in content) { parts.push([member, content[member]]); }
  return parts.map(item => item.map(part => encodeURIComponent(part)).join('='))
              .join('&');
}
