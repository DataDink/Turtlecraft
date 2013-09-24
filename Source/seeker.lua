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
		if (data == nil) then return nil; end
		local reader = string.gmatch(data, "[^,]+");
		return reader(), reader();
	end
	
	local whileFull = function()
		local wait = 0;
		while true do
			for i = 1, 16 do
				if (turtle.getItemCount(i) == 0) then 
					sleep(wait);
					return; 
				end
			end
			wait = 15;
			turtlecraft.term.clear("Inventory");
			turtlecraft.term.write(1, 5, "Please unload me...");
			sleep(1);
		end
	end
	
	local selectSlot = function() 
		local wait = 0;
		while true do
			for i = 2, 16 do
				if (turtle.getItemCount(i) > 0) then 
					sleep(wait);
					if (turtle.getItemCount(i) > 0) then 
						turtle.select(i);
						return i; 
					end
				end
			end
			wait = 15;
			turtlecraft.term.clear("Inventory");
			turtlecraft.term.write(1, 5, "Please add more inventory...");
			sleep(1);
		end
	end
	
	local eat = function(compare, direction)
		if (direction == nil) then 
			direction = directions.down; 
			if (turtle.detectUp() and not turtle.detectDown()) then direction = directions.up; end
		end
		
		if (compare and turtle.getItemCount(2) == 0) then
			turtle.select(2);
			turtlecraft.fuel.require(1);
			if (turtle.detectUp()) then 
				turtle.digUp();
				turtle.up();
			elseif (turtle.detectDown()) then 
				turtle.digDown();
				turtle.down();
			else
				turtlecraft.term.clear();
				turtlecraft.term.write(1, 5, "I need a sample block to unfill with.");
				turtlecraft.input.readKey(5);
				return;
			end
			cache.write("unfill", direction);
		else
			cache.write("eat", direction);
		end
		
		local checkUp = turtle.detectUp;
		local checkDown = turtle.detectDown;
		local check = turtle.detect;
		if (compare) then
			checkUp = function() turtle.select(2); return turtle.compareUp(); end
			checkDown = function() turtle.select(2); return turtle.compareDown(); end
			check = function() turtle.select(2); return turtle.compare(); end
		end
		
		local priority = { move = turtle.up, detect = checkUp, dig = turtle.digUp };
		local progress = { move = turtle.down, detect = checkDown, dig = turtle.digDown };
		if (direction == directions.up) then
			priority = { move = turtle.down, detect = checkDown, dig = turtle.digDown };
			progress = { move = turtle.up, detect = checkUp, dig = turtle.digUp };
		end
		
		local step = function()
			for i, turn in pairs(pattern) do
				turn();
				if (check()) then return true; end
			end
			return false;
		end
		
		local search = function()
			priority.move();
			for vert = 1, 3 do
				for horz = 1, 4 do
					turtlecraft.fuel.require(2);
					turtle.forward(); turtle.forward();
					if (priority.detect() or progress.detect() or step()) then return true; end
					turtle.turnLeft();
				end
				progress.move();
			end
			return false;
		end
		
		turtlecraft.term.clear("Munch Munch");
		turtlecraft.term.write(1, 5, "Press Q to stop");
		turtlecraft.input.escapeOnKey(16, function()
			while true do
				turtlecraft.fuel.require(1);
				whileFull();
				if (priority.detect()) then
					priority.dig();
					priority.move();
				elseif (step()) then
					while (check() and turtle.dig()) do sleep(0.5); end
					turtle.forward();
				elseif (progress.detect()) then
					while (progress.detect() and progress.dig()) do sleep(0.5); end
					progress.move();
				elseif (not search()) then
					turtlecraft.term.clear("All Gone?");
					turtlecraft.term.write(1, 5, "I got lost!");
					turtlecraft.input.readKey(10);
					return;
				end
			end
		end);
		cache.complete();
	end
	
	turtlecraft.seeker.eat = function(direction)
		eat(false, direction);
	end
	
	turtlecraft.seeker.unfill = function(direction)
		eat(true, direction);
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
		turtlecraft.term.write(1, 5, "Press Q to stop...");
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
		cache.complete();
	end
	
	local recover, dir = cache.read();
	if (recover ~= nil) then
		turtlecraft.seeker[recover](dir);
	end
end)();