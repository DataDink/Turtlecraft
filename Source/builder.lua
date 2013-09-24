turtlecraft.builder = {};

(function()
	local projectPath = turtlecraft.directory .. "project.data";
	local builderPath = turtlecraft.directory .. "builder.data";
	
	local project = {};
	project.data = {};
	project.load = function() 
		if (not fs.exists(projectPath)) then return false; end
		local file = fs.open(projectPath, "r").readAll() or "";
		project.data = {};
		local coords = string.gmatch(file, "[^,]+");
		for coord in coords do
			local vector = {x = tonumber(coord), y = tonumber(coords()), z = tonumber(coords())};
			table.insert(project.data, vector);
		end
		return true;
	end
	project.save = function()
		local file = "";
		for i, v in ipairs(project.data) do
			file = file .. v.x .. "," .. v.y .. "," .. v.z .. ",";
		end
		local handle = fs.open(projectPath, "w");
		handle.write(file);
		handle.close();
		read();
	end
	project.clear = function()
		project.data = {};
		fs.delete(projectPath);
	end
	project.load();
	
	local recover = {};
	recover.isEnabled = function()
		return fs.exists(builderPath);
	end
	recover.set = function(offset)
		local file = fs.open(builderPath, "w");
		file.write(offset.x .. "," .. offset.y .. "," .. offset.z);
		file.close();
	end
	recover.get = function()
		local file = fs.open(builderPath, "r");
		local reader = string.gmatch(file.readAll(), "[^,]+");
		file.close();
		return {
			x = tonumber(reader()),
			y = tonumber(reader()),
			z = tonumber(reader())
		};
	end
	recover.disable = function()
		fs.delete(builderPath);
	end

	-- calculations
	local calc = {};
	calc.round = function(number)
		if (number % 1 >= 0.5) then
			return math.ceil(number);
		else
			return math.floor(number);
		end
	end
	calc.plot = function(angle, distance)
		return {
			h = math.cos(math.rad(angle)) * distance,
			v = math.sin(math.rad(angle)) * distance
		};
	end
	calc.measure = function(x, y, z)
		if (x == nil) then x = 0; end
		if (y == nil) then y = 0; end
		if (z == nil) then z = 0; end
		return math.sqrt(x*x + y*y + z*z);
	end
	calc.angleStep = function(radius)
		return 45 / radius;
	end
	calc.rotateVector = function(vector, xaxis, yaxis, zaxis)
		if (xaxis == nil) then xaxis = 0; end
		if (yaxis == nil) then yaxis = 0; end
		if (zaxis == nil) then zaxis = 0; end
		
		if (xaxis == 0 and yaxis == 0 and zaxis == 0) then return; end

		if (xaxis ~= 0) then 
			local xcos = math.cos(math.rad(xaxis));
			local xsin = math.sin(math.rad(xaxis));
			local xz = xcos * vector.z - xsin * vector.y;
			local xy = xsin * vector.z + xcos * vector.y;
			vector.z = xz;
			vector.y = xy;
		end
		
		if (yaxis ~= 0) then
			local ycos = math.cos(math.rad(yaxis));
			local ysin = math.sin(math.rad(yaxis));
			local yx = ycos * vector.x - ysin * vector.z;
			local yz = ysin * vector.x + ycos * vector.z;
			vector.x = yx;
			vector.z = yz;
		end
		
		if (zaxis ~= 0) then
			local zcos = math.cos(math.rad(zaxis));
			local zsin = math.sin(math.rad(zaxis));
			local zx = zcos * vector.x - zsin * vector.y;
			local zy = zsin * vector.x + zcos * vector.y;
			vector.x = zx;
			vector.y = zy;
		end
	end
	calc.scaleVector = function(vector, xscale, yscale, zscale)
		if (xscale == nil) then xscale = 1; end
		if (yscale == nil) then yscale = 1; end
		if (zscale == nil) then zscale = 1; end
		if (xscale == 1 and yscale == 1 and zscale == 1) then return; end
		vector.x = vector.x * xscale;
		vector.y = vector.y * yscale;
		vector.z = vector.z * zscale;
	end
	calc.roundVector = function(vector)
		vector.x = calc.round(vector.x);
		vector.y = calc.round(vector.y);
		vector.z = calc.round(vector.z);
	end
	calc.line = function(from, to)
		local vectors = {};
		local vector = {
			x = to.x - from.x,
			y = to.y - from.y,
			z = to.z - from.z
		}
		local length = calc.measure(vector.x, vector.y, vector.z);
		for d = 0, length do
			table.insert(vectors, {
				x = from.x + vector.x / length * d,
				y = from.y + vector.y / length * d,
				z = from.z + vector.z / length * d
			});
		end
		return vectors;
	end
	
	-- collections
	local collection = {};
	collection.concat = function(table1, table2)
		local result = {};
		for i, v in ipairs(table1) do table.insert(result, v); end
		for i, v in ipairs(table2) do table.insert(result, v); end
		return result;
	end
	collection.group = function(objects, indexer)
		local results = {};
		local indexed = {};
		
		for i, object in ipairs(objects) do
			local key = indexer(object);
			if (indexed[key] == nil) then indexed[key] = {}; end
			table.insert(indexed[key], object);
		end
		
		local indexes = {};
		for key in pairs(indexed) do
			table.insert(indexes, key);
		end
		table.sort(indexes);
		
		for i, key in ipairs(indexes) do
			table.insert(results, indexed[key]);
		end
		return results;
	end
	collection.extractNearestVector = function(vectors, vector)
		if (vectors == nill or vector == nil or vectors[1] == nil) then return nil; end
		local index = 0;
		local distance = nil;
		
		for i, compare in ipairs(vectors) do
			local dist = calc.measure(compare.x - vector.x, compare.y - vector.y, compare.z - vector.z);
			if (distance == nil or dist < distance) then
				distance = dist;
				index = i;
			end
		end
		
		return table.remove(vectors, index);
	end
	collection.sortVectors = function(vectors)
		local results = {};
		
		local layers = collection.group(vectors, function(v) return v.z; end);
		for il, layer in ipairs(layers) do
			local sorted = {};
			local rows = collection.group(layer, function(v) return v.y; end);
			for ir, row in ipairs(rows) do
				local columns = collection.group(row, function(v) return v.x; end);
				for ic, column in ipairs(columns) do
					table.insert(sorted, column[1]);
				end
			end
			if (sorted[1] ~= nil) then
				local vector = table.remove(sorted, 1);
				table.insert(results, vector);
				
				while (sorted[1] ~= nil) do
					vector = collection.extractNearestVector(sorted, vector);
					table.insert(results, vector);
				end
			end
		end
			
		return results;
	end

	-- Shape generation
	local shape = {};
	shape.line = function(radius)
		return calc.line({x = -radius, y = 0, z = 0}, {x = radius, y = 0, z = 0});
	end
	shape.circle = function(radius)
		local vectors = {};
		local step = calc.angleStep(radius);
		for angle = 0, 360, step do
			local plot = calc.plot(angle, radius);
			table.insert(vectors, {x = plot.h, y = plot.v, z = 0});
		end
		return vectors;
	end
	shape.polygon = function(radius, sides)
		if (sides < 3) then return nil; end
		local vectors = {};
		local step = 360 / sides;
		local prevCorner = nil;
		for angle = 0, 360, step do
			corner = calc.plot(angle, radius);
			if (prevCorner ~= nil) then
				vectors = collection.concat(vectors, calc.line({
					x = prevCorner.h,
					y = prevCorner.v,
					z = 0
				}, {
					x = corner.h,
					y = corner.v,
					z = 0
				}));
			end
			prevCorner = corner;
		end
		return vectors;
	end
	
	-- Shape extrusion
	local extrude = {};
	extrude.tube = function(radius, crossSection)
		local result = {};
		for z = -radius, radius do
			for i, v in ipairs(crossSection) do
				table.insert(result, {
					x = v.x,
					y = v.y,
					z = z
				});
			end
		end
		return result;
	end
	extrude.cone = function(radius, crossSection)
		local result = {};
		for z = -radius, radius do
			local scale = 1 / radius * 2 * math.abs(z - radius);
			for i, v in ipairs(crossSection) do
				table.insert(result, {
					x = v.x * scale,
					y = v.y * scale,
					z = z
				});
			end
		end
		return result;
	end
	extrude.sphere = function(radius, crossSection)
		local result = {};
		local step = calc.angleStep(radius);
		for angle = 0, 180, step do
			local scalePlot = calc.plot(angle, radius);
			local z = scalePlot.h;
			local scale = scalePlot.v / radius;
			for i, v in ipairs(crossSection) do
				table.insert(result, {
					x = v.x * scale,
					y = v.y * scale,
					z = z
				});
			end
		end
		return result;
	end
	extrude.torus = function(radius, crossSection)
		local result = {};
		local step = calc.angleStep(radius);
		local edge = 0;
		for i, v in ipairs(crossSection) do
			if (v.x < edge) then edge = v.x; end
		end
		local adjust = radius - edge;
		for i, v in ipairs(crossSection) do
			v.x = v.x - adjust ;
			table.insert(result, v);
		end
		for angle = 0, 360, step do
			for i, v in ipairs(crossSection) do
				local vector = {x = v.x, y = v.y, z = v.z};
				calc.rotateVector(vector, 0, angle, 0);
				table.insert(result, vector);
			end
		end
		return result;
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
	
	local resume = function(offset)
		turtlecraft.term.clear("Build Project");
		turtlecraft.term.write(1, 4, "Press Q to cancel");
		turtlecraft.input.escapeOnKey(16, function() 
			local startFound = false;
			local x, y, z, d = turtlecraft.position.get();
			for i, v in ipairs(project.data) do
				local target = {
					x = v.x + offset.x,
					y = v.y + offset.y,
					z = v.z + offset.z
				};
				if (not startFound) then
					startFound = target.x == x and target.y == y and target.z == z;
				else
					turtlecraft.move.digTo(target.x, target.y, target.z);
					if (turtle.detectDown()) then turtle.digDown(); end
					selectSlot();
					turtle.placeDown();
				end
			end
		end);
		recover.disable();
	end
	
	turtlecraft.builder.clear = function()
		turtlecraft.term.clear("Delete Project");
		turtlecraft.term.write(1, 4, "You will lose all stored data.");
		turtlecraft.term.write(1, 5, "Are you sure? (y, n): ");
		
		if (read() == "y") then
			project.data = {};
			project.save();
			turtlecraft.term.clear("Delete Project");
			turtlecraft.term.write(1, 4, "Project erased!");
			sleep(3);
		else
			turtlecraft.term.clear("Delete Project");
			turtlecraft.term.write(1, 4, "Erase cancelled!");
			sleep(3);
		end
	end
	
	turtlecraft.builder.stats = function()
		turtlecraft.term.clear("Project Info");
		local blockCount = table.getn(project.data);
		
		if (blockCount == 0) then
			turtlecraft.term.write(1, 4, "Your project is empty");
			sleep(5);
			return;
		end
		
		local west = 0; local east = 0; local north = 0; local south = 0; local up = 0; local down = 0;
		for i, v in ipairs(project.data) do
			if (v.x < west) then west = v.x; end
			if (v.x > east) then east = v.x; end
			if (v.y > north) then north = v.y; end
			if (v.y < south) then south = v.y; end
			if (v.z > up) then up = v.z; end
			if (v.z < down) then down = v.z; end
		end
		
		turtlecraft.term.write(1, 4, "Block Count: " .. blockCount);
		turtlecraft.term.write(1, 5, math.abs(north) .. " blocks north.");
		turtlecraft.term.write(1, 6, math.abs(south) .. " blocks south.");
		turtlecraft.term.write(1, 7, math.abs(east) .. " blocks east.");
		turtlecraft.term.write(1, 8, math.abs(west) .. " blocks west.");
		turtlecraft.term.write(1, 9, math.abs(up) .. " blocks up.");
		turtlecraft.term.write(1, 10, math.abs(down) .. " blocks down.");
		turtlecraft.input.readKey(15);
	end
	
	turtlecraft.builder.start = function()
		if (table.getn(project.data) == 0) then
			turtlecraft.term.write(1, 4, "Your project is empty");
			sleep(5);
			return;
		end
		
		local start = project.data[1];
		local x, y, z, d = turtlecraft.position.get();
		local offset = {x = x, y = y, z = z};
		recover.set(offset);
		turtlecraft.move.digTo(start.x + offset.x, start.y + offset.y, start.z + offset.z);
		resume(offset);
	end

	turtlecraft.builder.add = function()
		turtlecraft.term.clear("Add Shape");
		turtlecraft.term.write(1, 4, "To create a shape you must select");
		turtlecraft.term.write(1, 5, "how many sides you want your base");
		turtlecraft.term.write(1, 6, "2D shape to be: (0 = circle, 1 = line)");
		turtlecraft.term.write(1, 7, "Sides: ");
		local sides = tonumber(read() or 0);
		local shapeMethod = shape.circle;
		if (sides == 1) then shapeMethod = shape.line; end
		if (sides > 1) then
			shapeMethod = function(radius) return shape.polygon(radius, sides); end;
		end
		
		turtlecraft.term.clear("Radius");
		turtlecraft.term.write(1, 4, "Now choose the radius of your base");
		turtlecraft.term.write(1, 5, "shape. (Radius is from center to edge)");
		turtlecraft.term.write(1, 6, "Radius: ");
		local radius = tonumber(read() or 0);
		
		if (radius == 0) then return; end
		
		turtlecraft.term.clear("Extrude Shape");
		turtlecraft.term.write(1, 4, "Now you must choose how to extrude your");
		turtlecraft.term.write(1, 5, "2D shape into a 3D shape: ");
		turtlecraft.term.write(1, 7, "1 = tube, 2 = cone, ");
		turtlecraft.term.write(1, 8, "3 = sphere, 4 = torus");
		turtlecraft.term.write(1, 9, "Enter nothing to keep this a 2D shape.");
		turtlecraft.term.write(1, 10, "Extrusion: ");
		local availableExtrusions = {"tube", "cone", "sphere", "torus"};
		local extrusion = read() or "";
		local index = tonumber(extrusion or 0);
		for i, v in ipairs(availableExtrusions) do
			if (index == i) then extrusion = v; break; end
			if (extrusion == v) then break; end
		end
		local extrudeMethod = function(radius, shape) return shape; end
		if (extrude[extrusion] ~= nil) then extrudeMethod = extrude[extrusion]; end
		
		local shape = {};
		if (extrusion == "torus") then
			turtlecraft.term.clear("Extrude Shape");
			turtlecraft.term.write(1, 4, "I need a radius for your torus.");
			turtlecraft.term.write(1, 5, "Radius: ");
			local tradius = tonumber(read() or 0);
			if (tradius == 0) then return; end
			shape = extrudeMethod(tradius, shapeMethod(radius));
		else
			shape = extrudeMethod(radius, shapeMethod(radius));
		end
		
		local squishX = 1; local squishY = 1; local squishZ = 1;
		turtlecraft.term.clear("Scale Shape");
		turtlecraft.term.write(1, 4, "Would you like to squish your shape?");
		turtlecraft.term.write(1, 5, "(y or n): ");
		if (read() == "y") then
			turtlecraft.term.write(1, 4, "Squish east-west...");
			turtlecraft.term.write(1, 5, "(1 - 100): ");
			squishX = math.max(1, math.min(100, tonumber(read() or 1))) / 100;
			
			turtlecraft.term.write(1, 4, "Squish north-south...");
			turtlecraft.term.write(1, 5, "(1 - 100): ");
			squishY = math.max(1, math.min(100, tonumber(read() or 1))) / 100;
			
			turtlecraft.term.write(1, 4, "Squish up-down...");
			turtlecraft.term.write(1, 5, "(1 - 100): ");
			squishZ = math.max(1, math.min(100, tonumber(read() or 1))) / 100;
		end
		
		local rotX = 0; local rotY = 0; local rotZ = 0;
		turtlecraft.term.clear("Rotate Shape");
		turtlecraft.term.write(1, 4, "Would you like to turn your shape?");
		turtlecraft.term.write(1, 5, "(y or n): ");
		if (read() == "y") then
			turtlecraft.term.write(1, 4, "Rotate east-west axis...");
			turtlecraft.term.write(1, 5, "(0 - 360): ");
			rotX = math.max(0, math.min(360, tonumber(read() or 0)));
			
			turtlecraft.term.write(1, 4, "Rotate north-south axis...");
			turtlecraft.term.write(1, 5, "(0 - 360): ");
			rotY = math.max(0, math.min(360, tonumber(read() or 0)));
			
			turtlecraft.term.write(1, 4, "Rotate up-down axis...");
			turtlecraft.term.write(1, 5, "(0 - 360): ");
			rotZ = math.max(0, math.min(360, tonumber(read() or 0)));
		end
		
		local offX = 0; local offY = 0; local offZ = 0;
		turtlecraft.term.clear("Offset Shape");
		turtlecraft.term.write(1, 4, "Would you like to offset your shape?");
		turtlecraft.term.write(1, 5, "(y or n): ");
		if (read() == "y") then
			turtlecraft.term.write(1, 4, "Offset east-west...");
			turtlecraft.term.write(1, 5, "(-500 to 500): ");
			offX = math.max(-500, math.min(500, tonumber(read() or 0)));
			
			turtlecraft.term.write(1, 4, "Offset north-south...");
			turtlecraft.term.write(1, 5, "(-500 to 500): ");
			offY = math.max(-500, math.min(500, tonumber(read() or 0)));
			
			turtlecraft.term.write(1, 4, "Offset up-down...");
			turtlecraft.term.write(1, 5, "(-500 to 500): ");
			offZ = math.max(-500, math.min(500, tonumber(read() or 0)));
		end
		
		turtlecraft.term.clear("Generating Shape");
		turtlecraft.term.write(1, 4, "Generating your shape...");
		
		for i, v in ipairs(shape) do
			calc.scaleVector(v, squishX, squishY, squishZ);
			calc.rotateVector(v, rotX, rotY, rotZ);
			v.x = v.x + offX;
			v.y = v.y + offY;
			v.z = v.z + offZ;
			calc.roundVector(v);
			table.insert(project.data, v);
		end
		project.data = collection.sortVectors(project.data);
		project.save();
		
		turtlecraft.term.clear("Add Shape");
		turtlecraft.term.write(1, 4, "All done!");
		sleep(5);
	end
	
	if (recover.isEnabled()) then
		local offset = recover.get();
		resume(offset);
	end
end)();