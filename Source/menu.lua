turtlecraft.menu = {}
turtlecraft.menu[1] = {
	title = "Dig functions",
	action = {};
}
	turtlecraft.menu[1].action = {};
	turtlecraft.menu[1].action[1] = {
		title = "Excavate",
		action = turtlecraft.excavate.start
	};
	turtlecraft.menu[1].action[2] = {
		title = "Eat Area",
		action = function() term.clear(); print("This is not yet implemented..."); read(); end
	};
	turtlecraft.menu[1].action[3] = {
		title = "Fill Area",
		action = function() term.clear(); print("This is not yet implemented..."); read(); end
	};
	turtlecraft.menu[1].action[4] = {
		title = "Empty Area",
		action = function() term.clear(); print("This is not yet implemented..."); read(); end
	};
	turtlecraft.menu[1].action[5] = {
		title = "Halp meh!",
		action = turtlecraft.help.dig
	};
	
turtlecraft.menu[2] = {
	title = "Build functions",
	action = {};
}
	turtlecraft.menu[2].action = {};
	turtlecraft.menu[2].action[1] = {
		title = "Clear project",
		action = function() term.clear(); print("This is not yet implemented..."); read(); end
	};
	turtlecraft.menu[2].action[2] = {
		title = "Add a shape",
		action = function() term.clear(); print("This is not yet implemented..."); read(); end
	};
	turtlecraft.menu[2].action[3] = {
		title = "Project stats",
		action = function() term.clear(); print("This is not yet implemented..."); read(); end
	};
	turtlecraft.menu[2].action[4] = {
		title = "Send to monitor",
		action = function() term.clear(); print("This is not yet implemented..."); read(); end
	};
	turtlecraft.menu[2].action[5] = {
		title = "Start building",
		action = function() term.clear(); print("This is not yet implemented..."); read(); end
	};
	turtlecraft.menu[2].action[6] = {
		title = "Halp meh!",
		action = turtlecraft.help.build
	};
	
turtlecraft.menu[3] = {
	title = "Halp meh!",
	action = turtlecraft.help.general
}



(function()
	local terminal = turtlecraft.term;
	local selectedIndex = 1;
	local history = {};
	table.insert(history, turtlecraft.menu);
	
	local writeLine = terminal.writeLine;
	
	local currentMenu = function()
		local item = history[table.getn(history)];
		return item;
	end
	
	local drawMenu = function()
		terminal.clear("Menu", "** Use up/down and left/enter keys **");
		
		local menu = currentMenu();
		for index, item in ipairs(menu) do
			local text = item.title;
			if (index == selectedIndex) then text = ">" .. text .. "<"; 
			else text = " " .. text; end
			terminal.scrolled(1, index, selectedIndex, text);
		end
	end
	
	local selectItem = function()
		local menu = currentMenu();
		local item = menu[selectedIndex].action;
		if (type(item) == "function") then
			item();
		else
			table.insert(history, item);
		end
	end
	
	local goBack = function()
		if (table.getn(history) > 1) then
			selectedIndex = 1;
			table.remove(history);
		end
	end
	
	local downArrow = function()
		local menu = currentMenu();
		if (selectedIndex < table.getn(menu)) then
			selectedIndex = selectedIndex + 1;
		end
	end
	
	local upArrow = function()
		if (selectedIndex > 1) then
			selectedIndex = selectedIndex - 1;
		end
	end
	
	if (not turtlecraft.position.isInSync()) then
		term.clear();
		writeLine(1, 1, "The turtle's position has gotten out of sync.");
		writeLine(1, 2, "If there was a function in progress it has likely been cancelled.");
		writeLine(1, 3, "Press any key to continue");
		local _, _, _, d = turtlecraft.position.get();
		turtlecraft.position.set(0, 0, 0, d);
		turtlecraft.input.readKey();
	end
	
	while (true) do
		drawMenu();
		sleep(0.01);
		local key = turtlecraft.input.readKey();
		if (key == 28) then selectItem(); end
		if (key == 200) then upArrow(); end
		if (key == 208) then downArrow(); end
		if (key == 203) then goBack(); end
	end
end)();