
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

minetest.register_craftitem("dssssa_rocks:gravel", {
	description = "Gravel mix",
	groups = {},
	inventory_image = "dssssa_rocks_gravel.png",
})

minetest.register_craftitem("dssssa_rocks:drill", {
	description = "broken Drill\nIt looks like someone (you!) didn't know how to use a drill, and just bonked it against stone as if it was hammer.",
	groups = {},
	inventory_image = "dssssa_crafting_drill2.png",
})

minetest.register_craftitem("dssssa_rocks:stick", {
	description = "Stick",
	groups = {},
	inventory_image = "dssssa_crafting_stick.png",
})

minetest.register_tool("dssssa_rocks:drill_on_stick", {
	description = "Drill on a Stick",
	groups = {},
	inventory_image = "dssssa_crafting_drill_stick2.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {
			cracky = {times = {2.2, 2.0, 1.8, 1.6, 1.4}, uses = 2000, maxlevel = 10},
		},
	},
})

minetest.register_craft({
	output = "dssssa_rocks:drill_on_stick",
	recipe = {
		{"dssssa_rocks:drill"},
		{"dssssa_rocks:stick"}
	},
})
