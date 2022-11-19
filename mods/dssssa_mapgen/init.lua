
local CHUNK_SIZE = 128
local ASTEREOIDS_PER_CHUNK = 10

local BENCH_DIFFT = 1

-- local CONTENT_ROCK = minetest.get_content_id("dssssa_rocks:rock1")

-- NOTE lua magen is generally slow optimization can be done later

-- this may change in the future

-- precalculations for schematics don't need to be fast
local function is_edge(x, y, z, xm, ym, zm, xo, yo, zo)
	return (z<=zo or z>zm-zo) and (y<=yo or y>ym-yo)
			or (x<=xo or x>xm-xo) and (y<=yo or y>ym-yo)
			or (x<=xo or x>xm-xo) and (z<=zo or z>zm-zo)
end

local function small_asteroid(nodename, xm, ym, zm)
	local data = {}
	
	-- flat table [z [y [x]]]
	-- starts at 1 and not 0
	for z = 1, zm, 1 do
	for y = 1, ym, 1 do
	for x = 1, xm, 1 do
		if is_edge(x, y, z, xm, ym, zm, 1, 1, 1) then
			data[(z-1)*ym*xm+(y-1)*xm+x] = {name = "air"}
		else
			data[(z-1)*ym*xm+(y-1)*xm+x] = {name = nodename}
		end
	end
	end
	end
	
	return minetest.register_schematic({
		size = {x=xm,y=ym,z=zm},
		data = data
	})
end

local function medium_asteroid(nodename, xm, ym, zm)
	local data = {}
	for z = 1, zm, 1 do
	for y = 1, ym, 1 do
	for x = 1, xm, 1 do
		if is_edge(x, y, z, xm, ym, zm, 2, 1, 1)
				or is_edge(x, y, z, xm, ym, zm, 1, 2, 1)
				or is_edge(x, y, z, xm, ym, zm, 1, 1, 2)
		then
			data[(z-1)*ym*xm+(y-1)*xm+x] = {name = "air"}
		else
			data[(z-1)*ym*xm+(y-1)*xm+x] = {name = nodename}
		end
	end
	end
	end
	
	return minetest.register_schematic({
		size = {x=xm,y=ym,z=zm},
		data = data
	})
end

local schems_medium = {
	medium_asteroid("dssssa_rocks:rock1", 13, 9, 10),
	medium_asteroid("dssssa_rocks:rock2", 12, 11, 9),
	medium_asteroid("dssssa_rocks:rock3", 12, 10, 10),
	medium_asteroid("dssssa_rocks:rock4", 13, 10, 9),
	medium_asteroid("dssssa_rocks:rock5", 12, 11, 9),
	medium_asteroid("dssssa_rocks:rock6", 13, 9, 9),
	medium_asteroid("dssssa_rocks:rock7", 11, 12, 9),
	medium_asteroid("dssssa_rocks:rock8", 10, 12, 9)
}

local schems_small = {
	small_asteroid("dssssa_rocks:rock1", 5, 5, 6),
	small_asteroid("dssssa_rocks:rock2", 5, 4, 6),
	small_asteroid("dssssa_rocks:rock3", 6, 6, 4),
	small_asteroid("dssssa_rocks:rock4", 5, 4, 7),
	small_asteroid("dssssa_rocks:rock5", 4, 5, 4),
	small_asteroid("dssssa_rocks:rock6", 6, 7, 5),
	small_asteroid("dssssa_rocks:rock7", 5, 6, 4),
	small_asteroid("dssssa_rocks:rock8", 7, 5, 4)
}

--local schems_large = {
	--medium_asteroid("dssssa_rocks:rock1", 25, 20, 23),
	--medium_asteroid("dssssa_rocks:rock2", 20, 23, 25),
	--medium_asteroid("dssssa_rocks:rock3", 25, 20, 21),
	--medium_asteroid("dssssa_rocks:rock4", 20, 24, 21),
	--medium_asteroid("dssssa_rocks:rock5", 21, 20, 25),
	--medium_asteroid("dssssa_rocks:rock6", 23, 20, 21),
	--medium_asteroid("dssssa_rocks:rock7", 22, 20, 22),
	--medium_asteroid("dssssa_rocks:rock8", 21, 21, 24)
--}

local schems_small_offset_rand = 1
local schems_medium_offset_rand = 4
--local schems_large_offset_rand = 5


local vol_sum = 0
local t_sum = 0

-- local vmanip_data = {}

local generate_chunk

local function vec_is_in(v, c1, c2)
	return v.x >= c1.x and v.y >= c1.y and v.z >= c1.z
			and v.x <= c2.x and v.y <= c2.y and v.z <= c2.z
end

minetest.register_on_generated(function(minp, maxp, _blockseed)
	local t0 = minetest.get_us_time()

	local vmanip, vmin, vmax = minetest.get_mapgen_object("voxelmanip")
	-- assert(vec_is_in(minp, vmin, vmax))
	-- assert(vec_is_in(maxp, vmin, vmax))
	-- local varea = VoxelArea(vmin, vmax)
	-- local varea = VoxelArea:new({MinEdge = vmin, MaxEdge = vmax})

	--vmanip:get_data(vmanip_data)

	-- split into 128^3 node chunks
	local min_chunk = vector.apply(minp, function(v) return math.floor(v / CHUNK_SIZE) end)
	local max_chunk = vector.apply(maxp, function(v) return math.floor(v / CHUNK_SIZE) end)

	for cy = min_chunk.y, max_chunk.y do
	for cx = min_chunk.x, max_chunk.x do
	for cz = min_chunk.z, max_chunk.z do
		local chunk_pos = vector.new(cx, cy, cz)
		generate_chunk(chunk_pos, minp, maxp, vmanip --[[, varea]])
	end
	end
	end

	--vmanip:set_data(vmanip_data)
	vmanip:calc_lighting()
	vmanip:write_to_map()

	local t1 = minetest.get_us_time()
	local area = (maxp - minp):offset(1, 1, 1)
	local vol = area.x * area.y * area.z
	vol = vol / 16^3
	vol_sum = vol_sum + vol
	t_sum = t_sum + (t1-t0)
	--~ minetest.log(string.format("took %s us for %s blocks (%s x %s x %s nodes)", t1-t0, vol, area.x, area.y, area.z))
end)

local function print_bench()
	minetest.log(string.format("took %s us (%s%%) for %s blocks", t_sum,
			t_sum * 10^-6 / BENCH_DIFFT, vol_sum))
	t_sum = 0
	vol_sum = 0

	minetest.after(BENCH_DIFFT, print_bench)
end

--~ print_bench()

generate_chunk = function(chunk_pos, minp, maxp , vmanip --[[, varea]])
	-- bounds of whole chunk
	local cminp = chunk_pos * CHUNK_SIZE
	local cmaxp = (chunk_pos:offset(1, 1, 1) * CHUNK_SIZE):offset(-1, -1, -1)
	-- intersect generated region with chunk
	minp = minp:combine(cminp, math.max)
	maxp = maxp:combine(cmaxp, math.min)

	local cseed = minetest.sha1(minetest.get_mapgen_setting("seed")..
			tostring(minetest.hash_node_position(chunk_pos)), true)
	local cseed_32 = string.byte(cseed, 1)
			+ (2^8) * string.byte(cseed, 2)
			+ (2^16) * string.byte(cseed, 3)
			+ (2^24) * string.byte(cseed, 4)
	local rand = PcgRandom(cseed_32)

	local astereoid_poss = {}
	for i = 1, ASTEREOIDS_PER_CHUNK do
		-- use local variables to ensure defined call order
		local rx = rand:next(cminp.x, cmaxp.x)
		local ry = rand:next(cminp.y, cmaxp.y)
		local rz = rand:next(cminp.z, cmaxp.z)
		astereoid_poss[i] = vector.new(rx, ry, rz)
	end

	for i, p in ipairs(astereoid_poss) do
		if vec_is_in(p, minp, maxp) then
			-- set_node is by far faster than vmanip, but it still takes > 1 ms for a mapchunk
			-- minetest.set_node(p, {name = "dssssa_rocks:rock1"})
			
			--vmanip:set_node_at(p, {name = "dssssa_rocks:rock1"})
			--vmanip_data[varea:indexp(p)] = CONTENT_ROCK
			
			
			-- maybe directly using minetest.place_schematic would be better
			
			-- this is not as fast as it could be
			
			
			local rock = rand:next(1, 8)
			if rock > 3 then
				rock = rand:next(1, 8)
			end
			if rock > 6 then
				rock = rand:next(1, 8)
			end
			
			local size = rand:next(1, 7)
			
			if size <= 2 then
				local rocks = rand:next(1, 3)
				for i = 1, rocks, 1 do
					p = vector.new(
						rand:next(p.x-schems_small_offset_rand, p.x+schems_small_offset_rand),
						rand:next(p.y-schems_small_offset_rand, p.y+schems_small_offset_rand),
						rand:next(p.z-schems_small_offset_rand, p.z+schems_small_offset_rand)
					)
					minetest.place_schematic_on_vmanip(vmanip, p, schems_small[rock], "random", {}, false, {
						place_center_x = true,
						place_center_y = true,
						place_center_z = true
					})
				end
			else
				local rocks
				if size > 6 then
					rocks = rand:next(5, 20)
				else
					rocks = rand:next(1, 5)
				end
				for i = 1, rocks, 1 do
					p = vector.new(
						rand:next(p.x-schems_medium_offset_rand, p.x+schems_medium_offset_rand),
						rand:next(p.y-schems_medium_offset_rand, p.y+schems_medium_offset_rand),
						rand:next(p.z-schems_medium_offset_rand, p.z+schems_medium_offset_rand)
					)
					minetest.place_schematic_on_vmanip(vmanip, p, schems_medium[rock], "random", {}, false, {
						place_center_x = true,
						place_center_y = true,
						place_center_z = true
					})
				end
			end
		end
	end
end
