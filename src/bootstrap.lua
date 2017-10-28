(function()
  local JSON = TurtleCraft.import('services/json');
  print(#JSON.parseArray('["a",1,false]'));
end)()
