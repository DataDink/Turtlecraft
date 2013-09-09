turtlecraft.position = {};
	
(function() 

	local directions = {
		forward = 270,
		backward = 90,
		left = 180,
		right = 0
	};
	turtlecraft.position.directions = directions;

	local facings = {};
	facings[0] = directions.forward;
	facings[1] = directions.right;
	facings[2] = directions.backward;
	facings[3] = directions.left;
	turtlecraft.position.facings = facings;

	local cache = {};
	cache.path = turtlecraft.directory + "position.data"
	cache.read = function() {
		if (not fs.exists(cache.path)) then return {x = 0, y = 0, z = 0, d = directions.forward}; end
		local handle = fs.open(cache.path, "r");
		if (handle == nil) then return {x = 0, y = 0, z = 0, d = directions.forward}; end
		
		local line = fs.readLine();
		if (line == nil) then return {x = 0, y = 0, z = 0, d = directions.forward}; end
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
		
		if (info.fuel > turtle.getFuelLevel()) then
			info.positionConfirmed = true;
		end
		
		reader = string.gmatch(line, "[^,]+");
		info.x = tonumber(reader());
		info.y = tonumber(reader());
		info.z = tonumber(reader());
		info.d = tonumber(reader());
	}
	cache.write = function(intended, previous) {
		local handle = fs.open(cache.path, "w");
		if (handle == nil) then return false; end
		handle.writeLine(intended.x .. "," .. intended.y .. "," .. intended.z .. "," .. intended.d + "," .. turtle.getFuelLevel());
		if (previous ~= nil) {
			handle.writeLine(previous.x .. "," .. previous.y .. "," .. previous.z .. "," .. previous.d);
		}
		handle.close();
		return true;
	}

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
	location.tryGetCustom = function() {
		-- TODO: add code here for RenEvo's custom location mod
		return nil;
	};
	
	-- Second most reliable - requires wonky GPS setup.
	location.tryGetGps = function() {
		if (rednet == nil or gps == nil) then return nil; end
		rednet.open("right");
		if (not rednet.isOpen("right")) then return nil; end
		local x, y, z = gps.locate(10);
		if (x == nil) then return nil; end
		return {
			x = x,
			y = y,
			z = z
		};
	};
	
	-- Gives us a reliable facing
	location.tryGetCompass = function() {
		if (getFacing == nil) then return nil; end
		return facings[getFacing()];
	};
	
	location.init = function() {
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
		else if (location.hasGps) then
			location.x = gpsReading.x;
			location.y = gpsReading.y;
			location.z = gpsReading.z;
			location.positionConfirmed = true;
		end
		
	};
	
	
end)();
