turtlecraft.seeker = {};

(function() 

	local path = turtlecraft.directory .. "seeker.data";
	local turtleBack = function(action) turtle.turnRight(); turtle.turnRight(); local result = action(); turtle.turnRight(); turtle.turnRight(); return result; end
	local directions = { up = "up", down = "down", forward = "forward" };
	local pattern = {turtle.turnRight, turtle.turnLeft, turtle.turnLeft, turtle.turnLeft};
	
	local cache = {};
	cache.write = function(func, direction)
		local file = fs.open(path, "w");
		file.write(func .. "," .. direction);
		file.close();
	end
	cache.complete = function()
		fs.delete(path);
	end
	cache.read = function()
		if (not fs.exists(path)) then return nil; end
		local file = fs.open(path, "r");
		local data = file.readLine();
		file.close();
		local reader = string.gmatch(data, "[^,]+");
		return reader(), reader();
	end
	
	local selectSlot = function() 
		while true do
			for i = 2, 16 do
				if (turtle.getItemCount(i) > 0) then 
					turtle.select(i);
					return i; 
				end
			end
			turtlecraft.term.clear("Fill");
			turtlecraft.term.write(1, 5, "Please add more inventory...");
			turtlecraft.input.onInventory();
			turtlecraft.term.write(1, 5, "Resuming in 15 seconds...");
			sleep(15);
			turtlecraft.term.write(1, 5, "Press Q to stop");
		end
	end
		
	turtlecraft.seeker.fill = function(direction)
		if (direction == nil) then 
			direction = directions.down; 
			if (turtle.detectDown() and not turtle.detectUp()) then direction = directions.up; end
		end
		cache.write("fill", direction);
		local priority = { move = turtle.up, detect = turtle.detectUp };
		local progress = { move = turtle.down, detect = turtle.detectDown, place = turtle.placeUp };
		if (direction == directions.up) then
			priority = { move = turtle.down, detect = turtle.detectDown };
			progress = { move = turtle.up, detect = turtle.detectUp, place = turtle.placeDown };
		end
		
		local step = function()
			for i, turn in pairs(pattern) do
				turn();
				if (turtle.back()) then return true; end
			end
			return false;
		end
		
		turtlecraft.term.clear("Fill");
		turtlecraft.term.write(1, 5, "Press Q to stop");
		turtlecraft.input.escapeOnKey(16, function() 
			while true do
				turtlecraft.fuel.require(1);
				if (not priority.detect()) then 
					priority.move();
				elseif (step()) then
					selectSlot();
					turtle.place();
				else
					turtle.turnLeft();
					turtle.turnLeft();
					if (progress.detect()) then
						turtlecraft.term.write(1, 5, "I got stuck!");
						turtlecraft.term.write(1, 6, "Press any key to continue");
						turtlecraft.input.readKey();
						return;
					end
					progress.move();
					selectSlot();
					progress.place();
				end							
			end
		end);
	end
end)();