-- Turtle position tracking as persistent as I can make it.

turtlecraft.position = {};

(function() 

	local directions = {
		north = 270,
		south = 90,
		west = 180,
		east = 0,
		up = 'up',
		down = 'down'
	};
	turtlecraft.position.directions = directions;

	local facings = {}; -- TODO: These need to be matched up with the turtlecraft directions
	facings[0] = directions.south;
	facings[1] = directions.west;
	facings[2] = directions.north;
	facings[3] = directions.east;
	turtlecraft.position.facings = facings;

	local location = {
		x = 0, 
		y = 0, 
		z = 0, 
		d = directions.north
	};
	
	local addons = {
		positionConfirmed = false,
		directionConfirmed = false,
		canSync = false,
		inSync = false,
	};

	local cache = {
		path = turtlecraft.directory .. "position.data"
	};

	cache.read = function() 
		local default = {
			x = location.x, y = location.y, z = location.z, d = location.d,
			positionConfirmed = false,
			directionConfirmed = false
		};
		if (not fs.exists(cache.path)) then return default; end
		local handle = fs.open(cache.path, "r");
		if (handle == nil) then return default; end
		
		local line1 = handle.readLine();
		local line2 = handle.readLine();
		handle.close();
		
		if (line1 == nil) then return default; end
		local reader = string.gmatch(line1, "[^,]+");
		local intended = {
			x = tonumber(reader()),
			y = tonumber(reader()),
			z = tonumber(reader()),
			d = tonumber(reader()),
			positionConfirmed = false,
			directionConfirmed = false
		};
		local fuel = tonumber(reader());
		
		if (line2 == nil) then 
			intended.positionConfirmed = true;
			intended.directionConfirmed = true;
			return intended; 
		end
		
		reader = string.gmatch(line2, "[^,]+");
		local previous = {
			x = tonumber(reader()),
			y = tonumber(reader()),
			z = tonumber(reader()),
			d = tonumber(reader())
		};
		
		if (fuel > turtle.getFuelLevel()) then
			intended.positionConfirmed = true;
			intended.directionConfirmed = true;
		elseif (fuel == turtle.getFuelLevel()) then
			intended.x = previous.x;
			intended.y = previous.y;
			intended.z = previous.z;
			intended.positionConfirmed = true;
			intended.directionConfirmed = intended.d == previous.d;
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
	
	addons.getPeripheral = function(ptype)
		local names = peripheral.getNames();
		for i, name in pairs(names) do
			if (peripheral.getType(name) == ptype) then
				local instance = peripheral.wrap(name);
				return instance;
			end
		end
		return nil;
	end
	
	-- Most reliable - but, sadly,  you may not be playing on RenEvo's custom server.
	addons.tryUpdateCustom = function()
		-- NYI
		return false;  
	end
	
	addons.tryReadGps = function()
		var side = "";
		if (peripheral.getType("right") == "modem") then side = "right"; end
		if (peripheral.getType("left") == "modem") then side = "left"; end
		if (side == "") then return nil; end
		
		rednet.open(side);
		if (not rednet.isOpen(side)) then return nil; end
		local x, z, y = gps.locate(10); -- I orientate my coordinates differently
		return x, y, z;
	end
	
	-- Second most reliable - requires wonky GPS setup. - no facing support
	addons.tryUpdateGps = function()
		local x, y, z = addons.tryReadGps();
		if (x == nil) then return false; end
		location.x = x;
		location.y = y;
		location.z = z;
		addons.positionConfirmed = true;
		addons.canSync = true;
		return true;
	end
	
	addons.tryUpdateCompass = function()
		local compass = addons.getPeripheral("compass");
		if (compass == nil or compass.getFacing == nil) then return false; end
		location.d = facings[compass.getFacing()];
		addons.directionConfirmed = true;
		return true;
	end
	
	addons.trySync = function()
		if (addons.directionConfirmed and addons.positionConfirmed) then return true; end
		if (not addons.canSync) then return false; end
		
		for turns = 1, 4 do
			if (not turtle.detect()) then break; end
			location.d = (location.d + 90) % 360;
			turtle.turnRight();
		end
		
		if (turtle.detect()) then return false; end
		turtle.forward();
		if (location.d == directions.north) then location.y = location.y + 1; end
		if (location.d == directions.south) then location.y = location.y - 1; end
		if (location.d == directions.east) then location.x = location.x + 1; end
		if (location.d == directions.west) then location.x = location.x - 1; end

		local x, y, z = addons.tryReadGps();

		if (location.d == directions.north and x < location.x) then location.d = directions.west; end
		if (location.d == directions.south and x < location.x) then location.d = directions.west; end
		if (location.d == directions.east and x < location.x and y == location.y) then location.d = directions.west; end
		if (location.d == directions.north and x > location.x) then location.d = directions.east; end
		if (location.d == directions.south and x > location.x) then location.d = directions.east; end
		if (location.d == directions.west and x > location.x and y == location.y) then location.d = directions.east; end
		if (location.d == directions.north and y < location.y and x == location.x) then location.d = directions.south; end
		if (location.d == directions.west and y < location.y) then location.d = directions.south; end
		if (location.d == directions.east and y < location.y) then location.d = directions.south; end
		if (location.d == directions.south and y > location.y and x == location.x) then location.d = directions.north; end
		if (location.d == directions.west and y > location.y) then location.d = directions.north; end
		if (location.d == directions.east and y > location.y) then location.d = directions.north; end
		
		turtle.back();
		cache.write(location);
		return true;
	end
	
	location.init = function() 
		local recovery = cache.read();
		location.x = recovery.x;
		location.y = recovery.y;
		location.z = recovery.z;
		location.d = recovery.d;
		
		addons.positionConfirmed = recovery.positionConfirmed;
		addons.directionConfirmed = recovery.directionConfirmed;
		
		if (not addons.tryUpdateCustom()) then
			addons.tryUpdateGps();
			addons.tryUpdateCompass();
		end
		
		addons.inSync = (addons.positionConfirmed and addons.directionConfirmed) or addons.trySync();
	end
	location.init();
	
	turtlecraft.position.isInSync = function() 
		return addons.inSync;
	end
	
	turtlecraft.position.syncTo = function(x, y, z, d)
		location.x = x;
		location.y = y;
		location.z = z;
		location.d = d;
		addons.inSync = true;
	end
	
	turtlecraft.position.get = function() 
		return location.x, location.y, location.z, location.d;
	end
	
	-- If moveAction does not exist or returns false: will consider out of sync.
	turtlecraft.position.set = function(x, y, z, d, moveAction, move) 
		local previous = {x = location.x, y = location.y, z = location.z, d = location.d};
		local intended = {x = x, y = y, z = z, d = d};
		cache.write(intended, previous, move);
		if (moveAction == nil or moveAction() == false) then return false; end
		cache.write(intended);

		location.x = x;
		location.y = y;
		location.z = z;
		location.d = d;
		return true;
	end
	

end)();
