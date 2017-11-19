var gulp = require('gulp');
var parse = require('luaparse').parse;
var minify = require('luamin').minify;
var fs = require('fs');
var dir = require('path');

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
  new Promise((success, error) => {
    var concat = fs.readFileSync('src/init.lua', 'utf8');
    concat = search('src/turtlecraft', /\.lua$/gi)
      .reduce((c, p) => (c + '\n' + fs.readFileSync(p, 'utf8')), concat);
    concat = fs.readFileSync('src/bootstrap.lua', 'utf8');
    concat = 'local cfgjson = ' + cfgjson + ';\n' + concat;

    rmdir('dst');
    mkdir('dst');

    fs.unlinkSync('dst/turtlecraft.lua');
    fs.writeFileSync('dst/turtlecraft.lua', concat);
    parse(concat);

    if (config.minify) {
      var minify = minify(concat);
      fs.writeFileSync('dist/turtlecraft.lua', minify);
    }
  }).then(() => complete())
  .catch(e => console.error(e));
});

gulp.task('test', c => {
  var results = search('src/turtlecraft', /\.lua$/gi);
  c();
});

function search(root, filter) {
  filter = filter || /.+/gi;
  root = dir.resolve(root);
  var results = Array.from(fs.readdirSync(root))
    .map(f => dir.join(root, f));
  return results
    .filter(f => fs.lstatSync(f).isDirectory())
    .reduce((files, directory) => {
      return files.concat(search(directory, filter));
    }, results.filter(f => filter.exec(f) && fs.lstatSync(f).isFile()));
}

function mkdir(path) {
  if (!path) { return; }
  mkdir(dir.dirname(path));
  if (fs.existsSync(path)) { return; }
  fs.mkdirSync(path);
}

function rmdir(path) {
  if (!fs.existsSync(path)) { return; }
  path = dir.resolve(path).replace(/^[\\\/]+|[\\\/]+$/gi, '');
  var results = Array.from(fs.readdirSync(path))
    .map(f => dir.join(path, f));
  results.filter(r => fs.lstatSync(r).isDirectory())
         .forEach(d => rmdir(d));
  results.filter(r => fs.lstatSync(r).isFile())
         .forEach(f => fs.unlinkSync(f));
  fs.rmdirSync(root);
}
