turtlecraft.position = {};

(function() 

	local directions = {
		forward = 270,
		backward = 90,
		left = 180,
		right = 0
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
	
	location.face = function(direction)
		if (direction == location.d) then return; end
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
	end
end)();
