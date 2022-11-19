
if not minetest.is_singleplayer() then
	error("Space-piracy-protection: You can only play this subgame in singleplayer-mode.", 5)
end

minetest.register_on_joinplayer(function(player)
	player:set_properties({
		textures = {"player.png", "player_back.png"},
		visual = "upright_sprite",
	})

	player:set_sky({
		base_color = "#000A21", -- dark blue fog
		type = "skybox",
		textures = {"dssssa_skybox_5.jpg", "dssssa_skybox_6.jpg", "dssssa_skybox_2.jpg",
				"dssssa_skybox_4.jpg", "dssssa_skybox_1.jpg", "dssssa_skybox_3.jpg"},
		clouds = false,
	})
	player:set_sun({
		sunrise_visible = false,
		scale = 0.5,
	})
	player:set_moon({
		visible = false,
	})
	player:set_lighting({
		shadows = {
			intensity = 0.5,
		},
	})
	minetest.set_timeofday(16000/24000)

	player:set_physics_override({gravity = 0}) -- space
	local name = player:get_player_name()
	local privs = minetest.get_player_privs(name)
	privs["fly"] = true -- jetpack
	minetest.set_player_privs(name, privs)
	-- enable jetpack. yes, this is ugly:
	-- * sets a setting globally (in general, I hate this, but it should be fine
	--   for enabling fly)
	-- * only works in singleplayer
	minetest.settings:set("free_move", "true")
end)
