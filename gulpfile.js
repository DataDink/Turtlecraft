var gulp = require('gulp');
var parse = require('luaparse').parse;
var minify = require('luamin').minify;
var fs = require('fs');
var dir = require('path');
const build = 'dst';
const output = dir.join(build, 'turtlecraft.lua');

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
    var content = loadlua('src/init.lua', 'utf8');
    content += search('src/turtlecraft', /\.lua$/gi)
      .reduce((c, p) => (c + '\n' + loadlua(p, 'utf8')), "");
    content += loadlua('src/bootstrap.lua', 'utf8');
    content = 'local cfgjson = ' + cfgjson + ';\n' + content;
    if (config.minify) { content = minify(content); }

    if (fs.existsSync(build)) { rmdir(build); }
    mkdir('dst');
    fs.writeFileSync(output, content);
    success();
  }).then(() => complete())
  .catch(e => console.error(e));
});

gulp.task('test', c => {
  console.log(dir.dirname('/'));
  c();
});

function loadlua(path) {
  var content = fs.readFileSync(path, 'utf8');
  try { parse(content); }
  catch (e) { console.error(path, e); }
  return content
}

function search(path, filter) {
  filter = filter || /.+/i;
  path = dir.resolve(path);
  var results = Array.from(fs.readdirSync(path))
    .map(f => dir.join(path, f));
  return results
    .filter(f => fs.lstatSync(f).isDirectory())
    .reduce((files, directory) => {
      return files.concat(search(directory, filter));
    }, results.filter(f => fs.lstatSync(f).isFile()));
}

function mkdir(path) {
  if (fs.existsSync(path)) { return; }
  mkdir(dir.dirname(path));
  fs.mkdirSync(path);
}

function rmdir(path) {
  if (!fs.existsSync(path)) { return; }
  path = dir.resolve(path);
  var results = Array.from(fs.readdirSync(path))
    .map(f => dir.join(path, f));
  results.filter(r => fs.lstatSync(r).isDirectory())
         .forEach(d => rmdir(d));
  results.filter(r => fs.lstatSync(r).isFile())
         .forEach(f => fs.unlinkSync(f));
  fs.rmdirSync(path);
}
