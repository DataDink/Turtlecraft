turtlecraft.help = {}

(function()
	local continue = function()
		print("Press any key to read more...");
		turtlecraft.input.readKey();
		term.clear();
		term.setCursorPos(1, 1);
	end

	local show = function(text)
		local width, height = term.getSize();
		term.clear();
		term.setCursorPos(1, 1);
		
		local row = 1;
		local rowText = "";
		local lines = string.gmatch(text, "[^\n]+");
		for line in lines do
			local words = string.gmatch(line, "%S+");
			for word in words do
				local word = word .. " ";
				local wordLength = string.len(word);
				local rowLength = string.len(rowText);
				if (rowLength + wordLength >= width - 1) then
					print(rowText);
					rowText = "";
					row = row + 1;
					if (row >= (height - 1)) then
						continue();
						row = 1;
					end
				end
				rowText = rowText .. word;
			end
			print(rowText);
			rowText = "";
			row = row + 1;
			if (row >= (height - 1)) then
				continue();
				row = 1;
			end
		end
		continue();
	end
	
	turtlecraft.help.general = function()
		local text = "Turtlecraft is a menu-driven system that will help you utilize your turtle for various creating, digging, and collection functions.\n"
		.. "Select 'Dig functions' to excavate, fill/clear areas, or 'eat'.\n"
		.. "Select 'Build functions' to have your turtle help you create 2d and 3d shapes.\n"
		.. "There is a whole world of things you can make your turtle do. Turtlecraft will only help you with these few things.\n";
		show(text);
	end
	
	turtlecraft.help.dig = function()
		local text = "Excavate: This will dig directly in front of the turtle's current position. "
		.. "You will be able to specify how far forward, left, right, up, and down to dig. "
		.. "The turtle will always try to unload directly behind it's start position when it is full. "
		.. "It will also return to its start position for more fuel when it is empty. "
		.. "If the turtle is unloaded or interrupted it will attempt to resume the next time it reloads "
		.. "automatically.\n\n"
		.. "Eat: This will attempt to eat blocks starting from its current location. "
		.. "This will not return when out of fuel or full of inventory. You will need to find "
		.. "and satisfy the turtle's needs.\n"
		.. "WARNING: This can end up very bad if left unattended! DO NOT LEAVE UNATTENDED!\n"
		.. "Fill: This will attempt to fill an area using a circulating movement pattern. "
		.. "This must be pre-loaded with blocks to unload and the turtle will not return "
		.. "to reload or refuel. This will not dig or break blocks for any reason.\n"
		.. "WARNING: Your turtle is very likely to get stuck when filling in non-box shapes. "
		.. "For non-box shapes always start the turtle in a small area to work its way into a large area "
		.. "to avoid boxing itself in a corner. YOU MAY LOSE YOUR TURTLE. \n\n"
		.. "Empty: Much like 'Eat', this will attempt to empty an area, but will only eat one type of block. "
		.. "The block that it will eat can either be pre-loaded into slot 2 (slot 1 is for fuel and ignored) "
		.. "or the turtle will eat the first block that it finds above or below and then only continue to eat that type. "
		.. "This uses a circulating movement pattern to find blocks and should probably not be left unattended. "
		.. "This will not return to refuel or unload and will instead wait for you to fix whatever it needs "
		.. "at whatever its current location.\n"
		.. "WARNING: This pattern may wander off. You should probably not leave this unattended.";
		show(text);
	end
	
	turtlecraft.help.build = function()
		local text = "Project: This is your virtual 3d 'canvas' that you are creating when adding shapes.\n"
		.. "Clear: This will erase all data from your project.\n"
		.. "Add: This will add a new shape (sphere, line, cube, etc...) to your project.\n"
		.. "Stats: This will calculate how many blocks and space your project requires.\n"
		.. "Send to monitor: This will attempt to render your current project on a monitor using ASCII art. "
		.. "The bigger your monitor the better you will be able to see what your project should look like "
		.. "when it is built.\n"
		.. "Start building: This will tell the turtle to start building your project. It will build from bottom "
		.. "to top and will not return to refuel or reload. If the turtle runs out of fuel or blocks to build with "
		.. "it must be given more supplies at its current position. If the turtle is unloaded or otherwise "
		.. "interrupted it will attempt to resume building upon reload.\n"
		.. "WARNING: Build recovery is not perfect, so there is still a small chance that when the turtle "
		.. "resumes building that it could get offset a square.";
		show(text);
	end
end)();