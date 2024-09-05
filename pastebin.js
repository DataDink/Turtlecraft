/******************************************************************************
 * PasteBin
 *  example: var pastebin = new Pastebin(devKey);
 *
 * METHOD                       DESCRIPTION
 * login(username, password)    Obtains a userkey for the given user credentials
 *                              returns: Promise
 * logout()                     Disassociates the Pastebin instance from the
 *                              previous login userkey
 * who()                        Gets user information
 *                              returns: Promise
 *                              requires: login
 * create(options)              Creates a new paste
 *                              returns: Promise
 *                              optional: login
 *                              options: {
 *                                content: 'string',
 *                                name: 'string', // optional
 *                                language: Pastebin.LANGUAGE_TEXT, // optional
 *                                expire: Pastebin.EXPIRE_NEVER, // optional
 *                                privacy: Pastebin.PRIVACY_PUBLIC, // optional
 *                              }
 * read(id)                     Downloads a paste
 *                              returns: Promise
 *                              requires: login
 * delete(id)                   Deletes a paste
 *                              returns: Promise
 *                              requires: login
 * list(limit)                  Lists the user's pastes
 *                              returns: Promise
 *                              requires: login
 * trending()                   Lists trending pastes
 *                              returns: Promise
 ******************************************************************************/

(function() {
  class Pastebin {
    constructor(devkey) {
      this._devkey = devkey;
    }

    login(username, password) {
      return new Promise((success, error) => {
        request('POST', '/api/api_login.php', {
          api_dev_key: this._devkey,
          api_user_name: username,
          api_user_password: password
        }).then(response => {
          this._userkey = response.data;
          success({response: response, pastebin: this});
        }).catch(response => { error(response.data); });
      });
    }

    logout() {
      delete this._userkey;
    }

    who() {
      if (!('_userkey' in this)) { throw 'who called without login'; }
      return new Promise((success, error) => {
        request('POST', '/api/api_post.php', {
          api_dev_key: this._devkey,
          api_user_key: this._userkey,
          api_option: 'userdetails'
        }).then(response => success({response: response, pastebin: this}))
        .catch(response => error(response.data));
      });
    }

    create(data) {
      if (typeof(data) === 'undefined') { throw 'create called with no data'; }
      return new Promise((success, error) => {
        data = typeof(data) === 'string' ? {content: data} : data;
        var options = {
          api_dev_key: this._devkey,
          api_option: 'paste'
        };
        if ('_userkey' in this) { options.api_user_key = this._userkey; }
        if ('content' in data) { options.api_paste_code = data.content; }
        if ('name' in data) { options.api_paste_name = data.name; }
        if ('language' in data) { options.api_paste_format = data.language; }
        if ('expire' in data) { options.api_paste_expire_date = data.expire; }
        if ('privacy' in data) { options.api_paste_private = data.privacy; }
        request('POST', '/api/api_post.php', options)
          .then(response => success({response: response, pastebin: this}))
          .catch(response => error(response.data));
      });
    }

    read(data) {
      data = typeof(data) === 'string' ? {id: data} : data;
      if (typeof(data) !== 'object') { throw 'read called without id'; }
      if (!('_userkey' in this)) { throw 'read called without login'; }
      return new Promise((success, error) => {
        request('POST', '/api/api_raw.php', {
          api_dev_key: this._devkey,
          api_user_key: this._userkey,
          api_paste_key: data.id,
          api_option: 'show_paste'
        }).then(response => success({response: response, pastebin: this}))
        .catch(response => error(response.data));
      });
    }

    delete(data) {
      data = typeof(data) === 'string' ? {id: data} : data;
      if (typeof(data) !== 'object') { throw 'delete called without id'; }
      if (!('_userkey' in this)) { throw 'delete called without login'; }
      return new Promise((success, error) => {
        request('POST', '/api/api_post.php', {
          api_dev_key: this._devkey,
          api_user_key: this._userkey,
          api_paste_key: data.id,
          api_option: 'delete'
        }).then(response => success({response: response, pastebin: this}))
        .catch(response => error(response.data));
      });
    }

    list(data) {
      data = typeof(data) === 'number' ? {limit: data} : data;
      data = data || {};
      if (!('_userkey' in this)) { throw 'list called without login'; }
      return new Promise((success, error) => {
        var options = {
          api_dev_key: this._devkey,
          api_user_key: this._userkey,
          api_option: 'list'
        };
        if ('limit' in data) { options.api_results_limit = data.limit; }
        request('POST', '/api/api_post.php', options)
          .then(response => success({response: response, pastebin: this}))
          .catch(response => error(response.data));
      });
    }

    trending() {
      return new Promise((success, error) => {
        request('POST', '/api/api_post.php', {
          api_dev_key: this._devkey,
          api_option: 'trends'
        }).then(response => success({response: response, pastebin: this}))
        .catch(response => error(response.data));
      });
    }


  }

  // CONSTANTS
  Object.defineProperty(Pastebin, 'PRIVACY_PUBLIC', {value: 0, writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'PRIVACY_UNLISTED', {value: 1, writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'PRIVACY_PRIVATE', {value: 2, writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'EXPIRE_NEVER', {value: 'N', writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'EXPIRE_10MIN', {value: '10M', writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'EXPIRE_1HOUR', {value: '1H', writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'EXPIRE_1DAY', {value: '1D', writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'EXPIRE_1WEEK', {value: '1W', writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'EXPIRE_2WEEK', {value: '2W', writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'EXPIRE_1MONTH', {value: '1M', writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'EXPIRE_6MONTH', {value: '6M', writable: false, enumerable: true});
  Object.defineProperty(Pastebin, 'EXPIRE_1YEAR', {value: '1Y', writable: false, enumerable: true});

  ['4cs', '6502acme', '6502kickass', '6502tasm', 'abap', 'actionscript', 'actionscript3', 'ada', 'aimms', 'algol68', 'apache', 'applescript', 'apt_sources', 'arm', 'asm', 'asp', 'asymptote', 'autoconf', 'autohotkey', 'autoit', 'avisynth', 'awk', 'bascomavr', 'bash', 'basic4gl', 'dos', 'bibtex', 'blitzbasic', 'b3d', 'bmx', 'bnf', 'boo', 'bf', 'c', 'c_winapi', 'c_mac', 'cil', 'csharp', 'cpp', 'cpp-winapi', 'cpp-qt', 'c_loadrunner', 'caddcl', 'cadlisp', 'ceylon', 'cfdg', 'chaiscript', 'chapel', 'clojure', 'klonec', 'klonecpp', 'cmake', 'cobol', 'coffeescript', 'cfm', 'css', 'cuesheet', 'd', 'dart', 'dcl', 'dcpu16', 'dcs', 'delphi', 'oxygene', 'diff', 'div', 'dot', 'e', 'ezt', 'ecmascript', 'eiffel', 'email', 'epc', 'erlang', 'euphoria', 'fsharp', 'falcon', 'filemaker', 'fo', 'f1', 'fortran', 'freebasic', 'freeswitch', 'gambas', 'gml', 'gdb', 'genero', 'genie', 'gettext', 'go', 'groovy', 'gwbasic', 'haskell', 'haxe', 'hicest', 'hq9plus', 'html4strict', 'html5', 'icon', 'idl', 'ini', 'inno', 'intercal', 'io', 'ispfpanel', 'j', 'java', 'java5', 'javascript', 'jcl', 'jquery', 'json', 'julia', 'kixtart', 'kotlin', 'latex', 'ldif', 'lb', 'lsl2', 'lisp', 'llvm', 'locobasic', 'logtalk', 'lolcode', 'lotusformulas', 'lotusscript', 'lscript', 'lua', 'm68k', 'magiksf', 'make', 'mapbasic', 'markdown', 'matlab', 'mirc', 'mmix', 'modula2', 'modula3', '68000devpac', 'mpasm', 'mxml', 'mysql', 'nagios', 'netrexx', 'newlisp', 'nginx', 'nimrod', 'text', 'nsis', 'oberon2', 'objeck', 'objc', 'ocaml-brief', 'ocaml', 'octave', 'oorexx', 'pf', 'glsl', 'oobas', 'oracle11', 'oracle8', 'oz', 'parasail', 'parigp', 'pascal', 'pawn', 'pcre', 'per', 'perl', 'perl6', 'php', 'php-brief', 'pic16', 'pike', 'pixelbender', 'pli', 'plsql', 'postgresql', 'postscript', 'povray', 'powershell', 'powerbuilder', 'proftpd', 'progress', 'prolog', 'properties', 'providex', 'puppet', 'purebasic', 'pycon', 'python', 'pys60', 'q', 'qbasic', 'qml', 'rsplus', 'racket', 'rails', 'rbs', 'rebol', 'reg', 'rexx', 'robots', 'rpmspec', 'ruby', 'gnuplot', 'rust', 'sas', 'scala', 'scheme', 'scilab', 'scl', 'sdlbasic', 'smalltalk', 'smarty', 'spark', 'sparql', 'sqf', 'sql', 'standardml', 'stonescript', 'sclang', 'swift', 'systemverilog', 'tsql', 'tcl', 'teraterm', 'thinbasic', 'typoscript', 'unicon', 'uscript', 'upc', 'urbi', 'vala', 'vbnet', 'vbscript', 'vedit', 'verilog', 'vhdl', 'vim', 'visualprolog', 'vb', 'visualfoxpro', 'whitespace', 'whois', 'winbatch', 'xbasic', 'xml', 'xorg_conf', 'xpp', 'yaml', 'z80', 'zxbasic'].forEach(name => {
    Object.defineProperty(Pastebin, 'LANGUAGE_' + name.toUpperCase().replace(/[^\w]+/gi, '_'), {
      value: name, writable: false, enumerable: true
    });
  });

  function request(method, path, data) {
    return new Promise((success, error) => {
      data = formatContent(data);
      var request = require('https').request({
        hostname: 'pastebin.com',
        path: path,
        method: method,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': Buffer.byteLength(data)
        }
      }, (response) => {
        var responseData = cloneResponse(response);
        responseData.data = '';
        response.on('data', (chunk) => { responseData.data += chunk; });
        response.on('end', () => {
          var isBad = responseData.data.match(/^\s*Bad\s/gi); // Everything from pastebin is a 200 - look for responses begining with the word "Bad"
          if (isBad) { error(responseData); }
          else { success(responseData); }
        });
      });
      request.on('error', (e) => { error({data: e}); });
      request.write(data);
      request.end();
    });
  }

  function cloneResponse(obj) {
    var clone = {};
    [ 'headers', 'statusCode', 'statusMessage' ]
      .forEach(m => clone[m] = obj[m]);
    return clone;
  }

  function formatContent(content) {
    if (typeof(content) === 'string') { return content; }
    if (typeof(content) !== 'object') { return ''; }
    var parts = [];
    for (var member in content) { parts.push([member, content[member]]); }
    return parts.map(item => item.map(part => encodeURIComponent(part)).join('='))
                .join('&');
  }

  if (typeof(module) !== 'undefined') { module.exports = Pastebin; }
  else if (typeof(window) !== 'undefined') { window.Pastebin = Pastebin; }
})();
