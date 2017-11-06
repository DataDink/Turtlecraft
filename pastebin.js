class PasteBin {
  constructor(devkey) {
    this._devkey = devkey;
  }

  login(username, password) {
    return new Promise((success, error) => {
      request('POST', 'api_login.php', {
        api_dev_key: this._devkey,
        api_user_name: username,
        api_user_password: password
      }).then(r => {
        this._userkey = r.content;
        success();
      }).catch(r => {
        error(r.content);
      });
    });
  }

  logout() {
    delete this._userkey;
  }

  create(data) {
    data = {
      api_dev_key: this._devkey,
      api_paste_code: data.content
    }
  }
}

function request(method, path, data) {
  return new Promise((success, error) => {
    data = formatContent(data);
    var request = require('https').request({
      hostname: 'pastebin.com',
      path: '/api/' + path,
      method: method,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(data)
      }
    }, (response) => {
      var responseData = cloneData(response);
      responseData.content = '';
      response.on('data', (chunk) => { responseData.content += chunk; });
      response.on('end', () => {
        var isBad = responseData.content.match(/^\s*Bad\s/gi);
        if (isBad) { error(response); }
        else { success(response); }
      });
    });
    request.on('error', (e) => { error(e, request); });
    request.write(data);
    request.end();
  });
}

function cloneData(obj) {
  var clone = {};
  for (var member in obj) {
    var value = obj[member];
    var type = typeof(value);
    if (['string', 'number', 'bool'].find(type) < 0) { continue; }
    clone[member] = value;
  }
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
