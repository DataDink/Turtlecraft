(function()
   function class:Menu(view, scroll)
      local options = {};
      local index = 1;

      local function render()
         view:refresh(false, 'up/down/left/enter h->help');
         local scrollMax = math.max(0, #options - view.content);
         local scroll = math.floor(index - (view.content / 2));
         scroll = math.max(0, math.min(scrollMax, scroll));
         for l = 1, view.content do
            local i = l + scroll;
            local option = options[i];
            if (option) then
               local text = option.text;
               text = (i == index and '>' or '|') .. text;
               view:write(text, view.headerHeight + l)
            else
               view:write('', view.headerHeight + l);
            end
         end
      end

      function self:add(text, action, help)
         table.insert(options, {text = text, action = action, help = (help or 'There is no help for this option.')});
      end

      function self:show(canExit)
         while true do
            render();
            local _, key = os.pullEvent('key');
            if (canExit and key == keys.left) then return; end
            if (key == keys.up) then index = math.max(1, index - 1); end
            if (key == keys.down) then index = math.min(#options, index + 1); end
            if (key == keys.enter or key == keys.numPadEnter) then
               term.clear();
               local option = options[index];
               option.action();
            end
            if (key == keys.h) then
               term.clear();
               local option = options[index];
               if (option.help) then scroll:show(option.help); end
            end
         end
      end
   end
   ModCraft.register.dependency.transient('menu', {'text-view', 'scroll-view', class.Menu});
end)();
