turtlecraft.position = {};

(function() 

	local directions = {
		forward = 270,
		backward = 90,
		left = 180,
		right = 0,
		up = 'up',
		down = 'down'
	};
	turtlecraft.position.directions = directions;

	local facings = {}; -- TODO: These need to be matched up with the turtlecraft directions
	facings[0] = directions.forward;
	facings[1] = directions.right;
	facings[2] = directions.backward;
	facings[3] = directions.left;
	turtlecraft.position.facings = facings;

	local cache = {};
	cache.path = turtlecraft.directory .. "position.data";
	cache.read = function() 
		local default = {
			x = 0, y = 0, z = 0, d = 0,
			positionConfirmed = false,
			directionConfirmed = false
		};
		if (not fs.exists(cache.path)) then return default; end
		local handle = fs.open(cache.path, "r");
		if (handle == nil) then return default; end
		
		local line = fs.readLine();
		if (line == nil) then return default; end
		local reader = string.gmatch(line, "[^,]+");
		local intended = {
			x = tonumber(reader()),
			y = tonumber(reader()),
			z = tonumber(reader()),
			d = tonumber(reader()),
			positionConfirmed = false,
			directionConfirmed = false
		};
		local fuel = tonumber(reader());

		line = fs.readLine();
		handle.close();
		
		if (line == nil) then 
			intended.positionConfirmed = true;
			intended.directionConfirmed = true;
			return intended; 
		end
		
		if (fuel > turtle.getFuelLevel()) then
			intended.positionConfirmed = true;
		end
		
		reader = string.gmatch(line, "[^,]+");
		if (not intended.positionConfirmed)
			intended.x = tonumber(reader());
			intended.y = tonumber(reader());
			intended.z = tonumber(reader());
			intended.d = tonumber(reader());
		end
		return intended;
	end
	cache.write = function(intended, previous) 
		local handle = fs.open(cache.path, "w");
		if (handle == nil) then return false; end
		handle.writeLine(intended.x .. "," .. intended.y .. "," .. intended.z .. "," .. intended.d + "," .. turtle.getFuelLevel());
		if (previous ~= nil) then
			handle.writeLine(previous.x .. "," .. previous.y .. "," .. previous.z .. "," .. previous.d);
		end
		handle.close();
		return true;
	end

	local location = {
		x = 0, 
		y = 0, 
		z = 0, 
		d = directions.forward,
		positionConfirmed = false,
		directionConfirmed = false,
		hasCustom = false,
		hasGps = false,
		hasCompass = false
	};
	
	-- Most reliable - but, sadly,  you may not be playing on RenEvo's custom server.
	location.tryGetCustom = function() 
		-- TODO: add code here for RenEvo's custom location mod
		return nil;
	end
	
	-- Second most reliable - requires wonky GPS setup. - no facing support
	location.tryGetGps = function() 
		if (rednet == nil or gps == nil) then return nil; end
		rednet.open("right");
		if (not rednet.isOpen("right")) then return nil; end
		local x, z, y = gps.locate(10); -- I orientate my coordinates differently
		if (x == nil) then return nil; end
		return {
			x = x,
			y = y,
			z = z
		};
	end
	
	-- Gives us a reliable facing. - no position support
	location.tryGetCompass = function() 
		if (getFacing == nil) then return nil; end
		return facings[getFacing()];
	end
	
	location.init = function() 
		local customReading = location.tryGetCustom();
		if (customReading ~= nil) then location.hasCustom = true; end
		local gpsReading = location.tryGetGps();
		if (gpsReading ~= nil) then location.hasGps = true; end
		local compassReading = location.tryGetCompass();
		if (compassReading ~= nil) then location.hasCompass = true; end
		local cacheReading = cache.read();
		
		location.x = cacheReading.x;
		location.y = cacheReading.y;
		location.z = cacheReading.z;
		location.d = cacheReading.d;
		location.positionConfirmed = cacheReading.positionConfirmed;
		location.directionConfirmed = cacheReading.directionConfirmed;
		
		if (location.hasCustom) then
			location.x = customReading.x;
			location.y = customReading.y;
			location.z = customReading.z;
			location.d = customReading.d;
			location.positionConfirmed = true;
			location.directionConfirmed = true;
		elseif (location.hasGps) then
			location.x = gpsReading.x;
			location.y = gpsReading.y;
			location.z = gpsReading.z;
			location.positionConfirmed = true;
		end
		if (location.hasCompass) then
			location.d = compassReading;
			location.directionConfirmed = true;
		end
	end
	location.init();
	
	location.confirm = function(beforeMove) -- assumes a forward movement only
		if (location.hasGps and (not location.directionConfirmed)) then
			local actualDirection = beforeMove.d
			if (beforeMove.x > location.x) then actualDirection = directions.right; end
			if (beforeMove.x < location.x) then actualDirection = directions.left; end
			if (beforeMove.y > location.y) then actualDirection = directions.forward; end
			if (beforeMove.y < location.y) then actualDirection = directions.backward; end
			if (actualDirection ~= beforeMove.d) then
				if (not turtle.back()) then return false; end
				location.d = actualDirection;
				location.directionConfirmed = true;
				location.face(beforeMove.d);
				if (not turtle.forward()) then return false; end
			end
		end
		return true;
	end
	
	location.face = function(direction)
		if (direction == location.d) then return; end
		if (direction == directions.up or direction == directions.down) then return; end
		if (direction % 90 ~= 0) then error("Position.lua location.face: direction was not % 90 degrees"); end
		if (direction == (location.d + 270) % 360) then
			turtle.turnLeft();
			location.d = direction;
			return;
		end
		while (direction ~= location.d) do
			turtle.turnRight();
			location.d = location.d + 90;
		end
	end
	
	location.move = function(direction, before, after, fail)
		local priorPosition = {x = location.x, y = location.y, z = location.z, d = location.d};
		location.face(direction);
		local expectedPosition = {x = location.x, y = location.y, z = location.z, d = location.d};
		
		local move = turtle.forward;
		if (direction == directions.up) then 
			move = turtle.up; 
			expectedPosition.z = expectedPosition.z + 1;
		end
		if (direction == directions.down) then 
			move = turtle.down; 
			expectedPosition.z = expectedPosition.z - 1;
		end
		if (direction == directions.forward) then expectedPosition.x = expectedPosition.x + 1; end
		if (direction == directions.backward) then expectedPosition.x = expectedPosition.x - 1; end
		if (direction == directions.left) then expectedPosition.y = expectedPosition.y - 1; end
		if (direction == directions.right) then expectedPosition.y = expectedPosition.y + 1; end
		
		if (before ~= nil) then before(); end
		
		cache.write(expectedPosition, priorPosition);
		local moveTries = 0;
		while (not move()) do
			moveTries = moveTries + 1;
			if (moveTries > 10) then 
				cache.write(location);
				return false; 
			end
			sleep(1);
			if (fail ~= nil) then fail(); end
		end
		cache.write(location);
		if (not location.confirm(priorPosition)) then return false; end
		location.x = expectedPosition.x;
		location.y = expectedPosition.y;
		location.z = expectedPosition.z;
		if (after ~= nil) then after(); end
		return true;
	end
	
	location.moveTo = function(targetPosition, before, after, fail)
		local x = turtlecraft.math.round(targetPosition.x);
		local y = turtlecraft.math.round(targetPosition.y);
		local z = turtlecraft.math.round(targetPosition.z);
		local xmove = nil;
		if (location.x > x) then xmove = directions.left; end
		if (location.x < x) then xmove = directions.right; end
		local ymove = nil;
		if (location.y > y) then ymove = directions.backward; end
		if (location.y < y) then ymove = directions.forward; end
		local zmove = nil;
		if (location.z > z) then zmove = directions.down; end
		if (location.z < z) then zmove = directions.up; end
		
		while (location.z ~= z) do
			if (not location.move(zmove, before, after, fail)) then return false; end
		end
		while (location.x ~= x) do
			if (not location.move(xmove, before, after, fail)) then return false; end
		end
		while (location.y ~= y) do
			if (not location.move(ymove, before, after, fail)) then return false; end
		end
		return true;
	end
	
	turtlecraft.position.getPosition = function() 
		return {x = location.x, y = location.y, z = location.z, d = location.d};
	end
	
	turtlecraft.position.inSync = function()
		return location.positionConfirmed and location.position.directionConfirmed;
	end
	
	turtlecraft.position.canSync = function()
		return (location.positionConfirmed or location.hasCustom or location.hasGps) and (location.directionConfirmed or location.hasCustom or location.hasCompass);
	end
	
	turtlecraft.position.face = function(direction)
		cache.write({x = location.x, y = location.y, z = location.z, d = direction}, location);
		location.face(direction);
		cache.write(location);
	end
	
	turtlecraft.position
end)();
