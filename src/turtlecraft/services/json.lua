TurtleCraft.export('services/json', function()
  local Json = {};

  Json.trim = function(remaining)
    return remaining:gsub('^%s|%s$');
  end

  Json.parseNull = function(remaining)
    remaining = Json.trim(remaining);
    if (not remaining:gmatch('^null')()) then return false, remaining:len(); end
    remaining = remaining:sub(4);
    return true, nil, remaining;
  end

  Json.parseNumber = function(remaining)
    remaining = Json.trim(remaining);
    local value = remaining:gmatch('^-?%d+|^-?%d+%.%d+')();
    if (value == nil) then return false, remaining:len(); end
    remaining = remaining:sub(value:len() + 1);
    return true, tonumber(value), remaining;
  end

  Json.parseBoolean = function(remaining)
    remaining = Json.trim(remaining);
    local value = remaining:lower():gmatch('^true|^false')();
    if (value == nil) then return false, remaining:len(); end
    remaining = remaining:sub(value:len() + 1);
    return true, value == 'true', remaining;
  end

  Json.parseString = function(remaining)
    remaining = Json.trim(remaining);
    if (remaining:sub(1,1) ~= '"') then return false, remaining:len(); end
    remaining = remaining:sub(2);
    local value = '';
    local chunk = remaining:gmatch('[^\\"]*[\\"]')();
    while (chunk ~= nil) do
      remaining = remaining:sub(chunk:len() + 1);
      if (chunk:sub(-1) == '"') then
        value = value .. chunk:sub(1, -2);
        return true, value, remaining;
      end

      value = value .. chunk:sub(1, -2);
      local chr = remaining:sub(1,1);
      remaining = remaining:sub(2);

      if (chr == '"') then value = value .. '"'; end
      if (chr == '\\') then value = value .. '\\'; end
      if (chr == '/') then value = value .. '/'; end
      if (chr == 'b') then value = value .. '\b'; end
      if (chr == 'f') then value = value .. '\f'; end
      if (chr == 'n') then value = value .. '\n'; end
      if (chr == 'r') then value = value .. '\r'; end
      if (chr == 't') then value = value .. '\t'; end
      if (chr == 'u') then
        local hex = tonumber(remaining:sub(1, 4), 16) % 256;
        remaining = remaining:sub(5);
        value = value .. string.char(hex);
      end
      chunk = remaining:gmatch('[^\\"]*[\\"]')();
    end
    return false, remaining:len();
  end

  Json.parseArray = function(remaining)
    remaining = Json.trim(remaining);
    if (remaining:sub(1,1) ~= '[') then return false, remaining:len(); end
    remaining = remaining:sub(2);
    local result = {};
    local valid, value, remaining = Json.parseNext(remaining);
    while (valid) do
      table.insert(result, value);
      remaining = Json.trim(remaining);
      local delim = remaining:sub(1, 1);
      remaining = remaining:sub(2);
      if (delim == ']') then return true, result, remaining; end
      if (delim ~= ',') then return false, remaining:len(); end
      valid, value, remaining = Json.parseNext(remaining);
    end
    return false, remaining:len();
  end

  Json.parseObject = function(remaining)
    remaining = Json.trim(remaining);
    if (remaining:sub(1,1) ~= '{') then return false, remaining:len(); end
    remaining = remaining:sub(2);
    local result = {};
    local valid, key, remaining = Json.parseString(remaining);
    while (valid) do
      remaining = Json.trim(remaining);
      if (remaining:sub(1,1) ~= ':') then return false, remaining:len(); end
      remaining = remaining:sub(2);
      local continue, value, remaining = Json.parseNext(remaining);
      if (not continue) then return false; end
      result[key] = value;
      remaining = Json.trim(remaining);
      local delim = remaining:sub(1,1);
      remaining = remaining:sub(2);
      if (delim == '}') then return true, result, remaining; end
      if (delim ~= ',') then return false, remaining:len(); end
      valid, key, remaining = Json.parseString(remaining);
    end
    return false, remaining:len();
  end

  Json.parseNext = function(remaining)
    for i, parser in ipairs({Json.parseNull, Json.parseNumber, Json.parseBoolean, Json.parseString, Json.parseArray, Json.parseObject}) do
      local success, value, remaining = parser(remaining);
      if (success) then return true, value, remaining; end
    end
    return false, remaining:len();
  end

  Json.parse = function(remaining)
    local success, value = Json.parseNext(remaining);
    if (success) then return value; else return nil; end
  end

  Json.format = function(value)
    if (type(value) == 'nil') then return 'null'; end
    if (type(value) == 'boolean') then return tostring(value); end
    if (type(value) == 'number') then return tostring(value); end
    if (type(value) == 'string') then
      value = value:gsub('\\', '\\\\');
      value = value:gsub('\"', '\\"');
      value = value:gsub('\/', '\\/');
      value = value:gsub('\b', '\\b');
      value = value:gsub('\f', '\\f');
      value = value:gsub('\n', '\\n');
      value = value:gsub('\r', '\\r');
      value = value:gsub('\t', '\\t');
      return '"' .. value .. '"';
    end
    if (type(value) == 'table' and #value) then
      local array = {};
      for i, content in ipairs(value) do
        table.insert(array, Json.format(content));
      end
      return '[' .. table.concat(array, ',') .. ']';
    end
    if (type(value) == 'table') then
      local array = {};
      for k, v in pairs(value) do
        table.insert(array, '"' .. k .. '":' .. Json.format(v));
      end
      return '{' .. table.concat(array, ',') .. '}';
    end
  end

  return Json;
end);
