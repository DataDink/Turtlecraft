turtlecraft.seeker = {};

(function() 

	local path = turtlecraft.directory .. "seeker.data";
	local turtleBack = function(action) turtle.turnRight(); turtle.turnRight(); local result = action(); turtle.turnRight(); turtle.turnRight(); return result; end
	local directions = { up = "up", down = "down", forward = "forward" };
	local methods = {
		up = {
			detect = turtle.detectUp,
			detectBack = turtle.detectDown,
			move = turtle.up,
			moveBack = turtle.down,
			dig = turtle.digUp,
			digBack = turtle.digDown,
			compare = turtle.compareUp,
			compareBack = turtle.compareDown,
			place = turtle.placeUp,
			placeBack = turtle.placeDown
		},
		down = {
			detect = turtle.detectDown,
			detectBack = turtle.detectUp,
			move = turtle.down,
			moveBack = turtle.up,
			dig = turtle.digDown,
			digBack = turtle.digUp,
			compare = turtle.compareDown,
			compareBack = turtle.compareUp
			place = turtle.placeDown,
			placeBack = turtle.placeUp
		},
		forward = {
			detect = turtle.detect,
			detectBack = function() return turtleBack(turtle.detect); end,
			move = turtle.forward,
			moveBack = turtle.back,
			dig = turtle.dig,
			digBack = function() return turtleBack(turtle.dig); end,
			compare = turtle.compare,
			compareBack = function() return turtleBack(turtle.compare); end,
			place = turtle.place,
			placeBack = function() return turtleBack(turtle.place); end
		}
	};
	
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
	
	local seekPattern = function(direction, empty)
		if (direction = directions.up and turtle.detectDown() ~= empty) then return methods.down; end
		if (direction = directions.down and turtle.detectUp() ~= empty) then return methods.up; end
		
		local pattern = {turtle.turnRight, turtle.turnLeft, turtle.turnLeft, turtle.turnLeft};
		for i, turn in pairs(pattern) do
			turn();
			if (turtle.detect() ~= empty) then return methods.forward; end
		end
		
		if (turtle.detectDown() ~= empty) then return methods.down; end
		if (turtle.detectUp() ~= empty) then return methods.up; end
		turtle.turnRight();
		turtle.turnRight();
		return nil;
	end
	
	local seekAndRecover = function(direction, empty)
		local result = seekPattern(direction, empty);
		if (result ~= nil) return result; end
		turtle.up();
		for v = 1, 3 do 
			for h = 1, 4 do
				turtle.forward();
				turtle.forward();
				turtle.turnRight();
				result = seekPattern;
				if (result ~= nil) return result; end
			end
		end
		return nil;
	end
	
	local selectSlot = function() 
		
	end
	
	turtlecraft.seeker.fill = function(direction)
		if (direction == nil) then 
			direction = directions.down; 
			if (turtle.detectDown() and not turtle.detectUp()) then direction = directions.up; end
		end
		cache.write("fill", direction);
		
		local method = false;
		repeat
			method = seekAndRecover(direction, true);
			if (method == methods.forward) then method.move();
			else 
			
	end
end)();