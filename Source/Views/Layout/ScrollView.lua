(function()
   function class .Views.Layout:ScrollView(view)
      function self:show(text, title)
         local lines = view:wrap(text or '');
         local scroll = 0;
         local scrollMax = math.max(0, #lines - view.content);
         while(true) do
            view:refresh(title, 'up/down enter->exit');
            for i = 1, view.content do
               local line = lines[scroll + i];
               if (not line) then break; end
               view:write(line, i + view.headerHeight);
            end
            local _, key = os.pullEvent('key');
            if (key == keys.enter or key == keys.numPadEnter) then return; end
            if (key == keys.up) then scroll = math.max(0, scroll - 1); end
            if (key == keys.down) then scroll = math.min(scrollMax, scroll + 1); end
         end
         term.clear();
      end
   end
   ModCraft.register.service('views.layout.scroll', {'views.layout.text', class.Views.Layout.ScrollView});
end)();
