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

	local location = {
		x = 0, 
		y = 0, 
		z = 0, 
		d = directions.forward
	};
	
	local addons = {
		positionConfirmed = false,
		directionConfirmed = false,
		canSync = false
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
		elseif (fuel == turtle.getFuelLevel()) then
			intended.x = previous.x;
			intended.y = previous.y;
			intended.z = previous.z;
			intended.positionConfirmed = true;
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
	
	-- if true than an adjustment was made and should be compensated by the caller
	addons.trySync = function()
		if (addons.directionConfirmed) then return false; end
		if (not addons.canSync) then return false; end
		
		local x, y, z = addons.tryReadGps();
		local actual = location.d;
		if (location.d == directions.forward and x < location.x) then actual = directions.left; end
		if (location.d == directions.backward and x < location.x) then actual = directions.left; end
		if (location.d == directions.right and x < location.x and y == location.y) then actual = directions.left; end
		if (location.d == directions.forward and x > location.x) then actual = directions.right; end
		if (location.d == directions.backward and x > location.x) then actual = directions.right; end
		if (location.d == directions.left and x > location.x and y == location.y) then actual = directions.right; end
		if (location.d == directions.forward and y < location.y and x == location.x) then actual = directions.backward; end
		if (location.d == directions.left and y < location.y) then actual = directions.backward; end
		if (location.d == directions.right and y < location.y) then actual = directions.backward; end
		if (location.d == directions.backward and y > location.y and x == location.x) then actual = directions.forward; end
		if (location.d == directions.left and y > location.y) then actual = directions.forward; end
		if (location.d == directions.right and y > location.y) then actual = directions.forward; end
		
		local adjustRequired = x ~= location.x or y ~= location.y or z ~= location.z or actual ~= location.d;
		if (adjustRequired) then
			location.x = x;
			location.y = y;
			location.z = z;
			location.d = actual;
		end
		return adjustRequired;
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
	end
	
	turtlecraft.position.get = function() 
		return location.x, location.y, location.z, location.d;
	end
	
	-- Will fail if a syncronization change happened.
	turtlecraft.position.set = function(x, y, z, d, moveAction) 
		local previous = {x = location.x, y = location.y, z = location.z, d = location.d};
		local intended = {x = x, y = y, z = z, d = d};
		if (moveAction ~= nil) then
			cache.write(indended, previous);
			moveAction();
			if (location.trySync()) then return false; end
		end
		cache.write(intended);
		location.x = x;
		location.y = y;
		location.z = z;
		location.d = d;
		return true;
	end
	

end)();
