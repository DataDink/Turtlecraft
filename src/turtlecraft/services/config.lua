TurtleCraft.export('services/config', function()
  -- NOTE: cfgjson will be added to the turtlecraft scope at build time
  local config =  TurtleCraft.import('services/json').parse(cfgjson or '{}');
  config.recoveryPath = config.recoveryPath:gsub('[%s/]+$', '');
  config.logsPath = config.logsPath:gsub('[%s/]+$', '');
  return config;
end);
