
minetest.register_node("dssssa_rocks:rock1", {
	description = "Rock",
	groups = {cracky = 3},
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
