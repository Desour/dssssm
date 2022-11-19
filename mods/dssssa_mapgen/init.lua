
local CHUNK_SIZE = 128
local ASTEREOIDS_PER_CHUNK = 123

local BENCH_DIFFT = 1

local CONTENT_ROCK = minetest.get_content_id("dssssa_rocks:rock1")

local vol_sum = 0
local t_sum = 0

--~ local vmanip_data = {}

local generate_chunk

local function vec_is_in(v, c1, c2)
	return v.x >= c1.x and v.y >= c1.y and v.z >= c1.z
			and v.x <= c2.x and v.y <= c2.y and v.z <= c2.z
end

minetest.register_on_generated(function(minp, maxp, _blockseed)
	local t0 = minetest.get_us_time()

	--~ local vmanip, vmin, vmax = minetest.get_mapgen_object("voxelmanip")
	--~ assert(vec_is_in(minp, vmin, vmax))
	--~ assert(vec_is_in(maxp, vmin, vmax))
	--~ local varea = VoxelArea(vmin, vmax)

	--~ vmanip:get_data(vmanip_data)

	-- split into 128^3 node chunks
	local min_chunk = vector.apply(minp, function(v) return math.floor(v / CHUNK_SIZE) end)
	local max_chunk = vector.apply(maxp, function(v) return math.floor(v / CHUNK_SIZE) end)

	for cy = min_chunk.y, max_chunk.y do
	for cx = min_chunk.x, max_chunk.x do
	for cz = min_chunk.z, max_chunk.z do
		local chunk_pos = vector.new(cx, cy, cz)
		generate_chunk(chunk_pos, minp, maxp--[[, vmanip, varea]])
	end
	end
	end

	--~ vmanip:set_data(vmanip_data)
	--~ vmanip:write_to_map()

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

generate_chunk = function(chunk_pos, minp, maxp--[[, vmanip, varea]])
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
			minetest.set_node(p, {name = "dssssa_rocks:rock1"})
			--~ vmanip:set_node_at(p, {name = "dssssa_rocks:rock1"})
			--~ vmanip_data[varea:indexp(p)] = CONTENT_ROCK
		end
	end
end
