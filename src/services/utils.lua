TurtleCraft.Services.Utils = {
  string = {
    split = function(delimiter, content)
      delimiter = string.gsub(delimiter, "%%", "%%");
      delimiter = string.gsub(delimiter, "%(", "%(");
      delimiter = string.gsub(delimiter, "%)", "%)");
      delimiter = string.gsub(delimiter, "%.", "%.");
      delimiter = string.gsub(delimiter, "%+", "%+");
      delimiter = string.gsub(delimiter, "%-", "%-");
      delimiter = string.gsub(delimiter, "%*", "%*");
      delimiter = string.gsub(delimiter, "%?", "%?");
      delimiter = string.gsub(delimiter, "%[", "%[");
      delimiter = string.gsub(delimiter, "%^", "%^");
      delimiter = string.gsub(delimiter, "%$", "%$");
      return string.gmatch("[^" .. delimiter .. "]+");
    end,
  },

  path = {
    split = function(path)
      return string.gmatch(path or "", "[^/]+");
    end,

    normalize = function(path)
      local parts = TurtleCraft.Helpers.Utils.path.split(path);
      return table.concat(parts, "/") .. "/";
    end,

    select = function(path, query)
      local pathParts = ipairs(TurtleCraft.Helpers.Utils.path.split(path));
      local queryParts = ipairs(TurtleCraft.Helpers.Utils.path.split(query));
      local pathPart = pathParts();
      local queryPart = queryParts();

      local result = {root = ""};
      while (pathPart and queryPart and string.lower(pathPart) == string.lower(queryPart)) do
        result.root = result.root .. pathPart;
        pathPart = pathParts();
        queryPart = queryParts();
      end
      if (not pathPart) then return result; end

      result.target = pathPart;
      pathPart = pathParts();
      result.next = pathPart;

      while (pathPart) do
        result.remainder = (result.remainder or "") .. pathPart;
        pathPart = pathParts();
      end

      return result;
    end,

    combine = function(root, path)
      return TurtleCraft.Helpers.Utils.normalize(root) .. TurtleCraft.Helpers.Utils.normalize(path);
    end,

    regress = function(path, ...)
      local count = select(1, ...) or 1;
      local parts = TurtleCraft.Helpers.Utils.path.split(path);
      for i = 0, count do
        if (table.getn(parts) == 0) then return ""; end
        table.remove(parts, table.getn(parts));
      end
      return table.concat(parts, "/") .. "/";
    end
  }
};
