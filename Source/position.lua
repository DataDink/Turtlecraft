-- Turtle position tracking as persistent as I can make it.

turtlecraft.position = {
	inSync = false;
};

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
	facings[0] = directions.north;
	facings[1] = directions.east;
	facings[2] = directions.south;
	facings[3] = directions.west;
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
	};

	local cache = {
		path = turtlecraft.directory .. "position.data"
	};

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
		local move = reader();

		line = fs.readLine();
		handle.close();
		
		if (line == nil) then 
			intended.positionConfirmed = true;
			intended.directionConfirmed = true;
			return intended; 
		end
		
		reader = string.gmatch(line, "[^,]+");
		local previous = {
			x = tonumber(reader()),
			y = tonumber(reader()),
			z = tonumber(reader()),
			d = tonumber(reader())
		};
		
		if (fuel > turtle.getFuelLevel()) then
			intended.positionConfirmed = true;
			intended.directionConfirmed = true;
		elseif (move ~= nil and move ~= "" and turtle[move] ~= nil and turtle[move]()) then
			intended.positionConfirmed = true;
			intended.directionConfirmed = true;
		elseif (fuel == turtle.getFuelLevel()) then
			intended.x = previous.x;
			intended.y = previous.y;
			intended.z = previous.z;
			intended.positionConfirmed = true;
		end

		return intended;
	end
	cache.write = function(intended, previous, move) 
		local handle = fs.open(cache.path, "w");
		if (handle == nil) then return false; end
		local line = intended.x .. "," .. intended.y .. "," .. intended.z .. "," .. intended.d + "," .. turtle.getFuelLevel();
		if (move ~= nil) then line = line .. "," .. move;
		handle.writeLine(line);
		if (previous ~= nil) then
			line = previous.x .. "," .. previous.y .. "," .. previous.z .. "," .. previous.d;
			handle.writeLine(line);
		end
		handle.close();
		return true;
	end
	
	-- Most reliable - but, sadly,  you may not be playing on RenEvo's custom server.
	addons.tryUpdateCustom = function()
		-- Unknown yet
		return false;  
	end
	
	addons.tryReadGps()
		if (rednet == nil or gps == nil) then return nil; end
		rednet.open("right");
		if (not rednet.isOpen("right")) then return nil; end
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
		if (getFacing == nil) then return false; end
		location.d = facings[getFacing()];
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
			if (not addons.tryUpdateGps()) then
				addons.tryUpdateCompass();
			end
		end
		
		turtlecraft.position.inSync = (addons.positionConfirmed and addons.directionConfirmed) or location.trySync();
	end
	
	turtlecraft.position.get = function() 
		return location.x, location.y, location.z, location.d;
	end
	
	-- If moveAction does not exist or returns false: will consider out of sync.
	turtlecraft.position.set = function(x, y, z, d, moveAction, move) 
		local previous = {x = location.x, y = location.y, z = location.z, d = location.d};
		local intended = {x = x, y = y, z = z, d = d};
		cache.write(intended, previous, move);
		if (moveAction == nil || moveAction() == false) then return false; end
		cache.write(intended);

		location.x = x;
		location.y = y;
		location.z = z;
		location.d = d;
		return true;
	end
	

end)();
