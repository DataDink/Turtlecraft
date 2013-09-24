turtlecraft.builder = {};

(function()
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
	calc.ajustVectors = function(vectors, xscale, yscale, zscale, xaxis, yaxis, zaxis)
		for i, vector in ipairs(vectors) do
			calc.scaleVector(vector, xscale, yscale, zscale);
			calc.rotateVector(vector, xaxis, yaxis, zaxis);
			calc.roundVector(vector);
		end
		return collection.sortVectors(vectors);
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

	
end)();