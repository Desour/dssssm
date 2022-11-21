
minetest.register_node("dssssa_rocks:rock1", {
	description = "Light Gray Rock",
	groups = {cracky = 1, rawrock = 1},
	drawtype = "normal",
	tiles = {"dssssa_rocks_rock1.png"},
	paramtype = "none",
	paramtype2 = "none",
	is_ground_content = false, -- space should have no caves
	--~ sounds = { -- no sound in space, so don't care much
		--~ dig = <SimpleSoundSpec> or "__group",
		--~ dug = <SimpleSoundSpec>,
		--~ place = <SimpleSoundSpec>,
	--~ },
})

minetest.register_node("dssssa_rocks:rock2", {
	description = "Gray Rock",
	groups = {cracky = 2, rawrock = 1},
	drawtype = "normal",
	tiles = {"dssssa_rocks_rock2.png"},
	paramtype = "none",
	paramtype2 = "none",
	is_ground_content = false,
})

minetest.register_node("dssssa_rocks:rock3", {
	description = "Dark Gray Rock",
	groups = {cracky = 3, rawrock = 1},
	drawtype = "normal",
	tiles = {"dssssa_rocks_rock3.png"},
	paramtype = "none",
	paramtype2 = "none",
	is_ground_content = false,
})

minetest.register_node("dssssa_rocks:rock4", {
	description = "Yellow Rock",
	groups = {cracky = 1, rawrock = 1},
	drawtype = "normal",
	tiles = {"dssssa_rocks_rock4.png"},
	paramtype = "none",
	paramtype2 = "none",
	is_ground_content = false,
})

minetest.register_node("dssssa_rocks:rock5", {
	description = "Light Blue Rock",
	groups = {cracky = 3, rawrock = 1},
	drawtype = "normal",
	tiles = {"dssssa_rocks_rock5.png"},
	paramtype = "none",
	paramtype2 = "none",
	is_ground_content = false,
})

minetest.register_node("dssssa_rocks:rock6", {
	description = "Red Rock",
	groups = {cracky = 2, rawrock = 1},
	drawtype = "normal",
	tiles = {"dssssa_rocks_rock6.png"},
	paramtype = "none",
	paramtype2 = "none",
	is_ground_content = false,
})

minetest.register_node("dssssa_rocks:rock7", {
	description = "Dark Blue Rock",
	groups = {cracky = 2, rawrock = 1},
	drawtype = "normal",
	tiles = {"dssssa_rocks_rock7.png"},
	paramtype = "none",
	paramtype2 = "none",
	is_ground_content = false,
})

minetest.register_node("dssssa_rocks:rock8", {
	description = "Cyan Rock",
	groups = {cracky = 3, rawrock = 1},
	drawtype = "normal",
	tiles = {"dssssa_rocks_rock8.png"},
	paramtype = "none",
	paramtype2 = "none",
	is_ground_content = false,
})

minetest.register_node("dssssa_rocks:blackbox", {
	description = "Blackbox",
	groups = {cracky = 4},
	drawtype = "normal",
	tiles = {"dssssa_rocks_blackbox.png"},
	paramtype = "none",
	paramtype2 = "none",
	is_ground_content = false,
})
