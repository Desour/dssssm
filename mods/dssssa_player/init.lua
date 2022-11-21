
dssssa_player = {}

if not minetest.is_singleplayer() then
	error("Space-piracy-protection: You can only play this subgame in singleplayer-mode.", 5)
end

local modstorage = minetest.get_mod_storage()

local log_entries = {
[[
Logbook of the captain, startime 2 days ago:
I've accepted a mission to deliver a resupply of chicken eggs to the research
outpost on Giesela 235 C.
The fuel tank is only filled to three fourths, so I will just barely make the
jump. This is dangerous, but due to the jump distance, I'd be much longer in
jump space if the ship had more mass, and my employer would pay me less.
]],
[[
Logbook of the captain, startime today:
I arrived at the coordinates of Giesela 235, however I'm just surrounded by rocks,
there's no planet in sight. The navigation computer is sure I'm at the right place
and a spectrum analysis of the start showed that it's indeed Giesela 235 A. Also,
all the other planets recorded in the database are where they should be.
This all leads to only one possible conclusion: Some horrible thing must have
happened to Giesela 235 C, and turned into an asteroid field. But even this is
weird, the planet's core should've left a hot soup of lava, but there is almost
none.
As I'm now stranded here with not even enough fuel to emit a distress signal, I'll
have to stay here and scoop for fuel. Also, while I'm here, I should investigate
this disaster, maybe someone will pay me for the data of a black box.
I've found a broken drill and a stick in the cargo hold, maybe I can make use of
those.
]],
[[
Logbook of the captain, startime today (1):
enoguh power => detect signal of blackbox
]],
[[
Logbook of the captain, startime today (2):
blackbox broken, uses RAID, search more
]],
[[
Logbook of the captain, startime today (3):
found 3 blackboxes
cult of "those that seek the approval of Krock the core devourer" came to planet
giant crocodile cracked planet like a nutcracker, then sucked up the core
have to warn other ppl
]],
}

minetest.register_on_joinplayer(function(player)
	local first_join = modstorage:get("not_first_join") ~= "true"
	if first_join then
		modstorage:set_string("not_first_join", "true")
		modstorage:set_string("ship_log", "...\n\n"..log_entries[1].."\n"..log_entries[2])
	end

	player:set_properties({
		textures = {"player.png", "player_back.png"},
		visual = "upright_sprite",
	})

	player:set_sky({
		base_color = "#020307", -- dark blue fog (color from skybox)
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

	if first_join then
		dssssa_ship.ship = assert(minetest.add_entity(player:get_pos(), "dssssa_ship:ship")):get_luaentity()
		dssssa_ship.into_ship(player)
	else
		dssssa_player.is_in_ship = false
	end

	dssssa_player.current_inv_tab = 1
	dssssa_player.set_inventory_formspec(player)

	if first_join then
		minetest.after(0, minetest.show_formspec, name, "inv", player:get_inventory_formspec())
	end
end)

function dssssa_player.set_inventory_formspec(player)
	local fs = "formspec_version[6]"
			.."size[10.25,10]"

	if dssssa_player.is_in_ship then
		fs = fs
			.."tabheader[0,0;tabhdr;Logbook,Crafting,Steering,Ship-AI;"..dssssa_player.current_inv_tab..";true;true]"

		if dssssa_player.current_inv_tab == 1 then -- logbook
			fs = fs
		elseif dssssa_player.current_inv_tab == 2 then -- Crafting
			fs = fs
				.."list[current_player;main;0.25,5;8,4;0]"
		elseif dssssa_player.current_inv_tab == 3 then -- Steering
			fs = fs
				.."button[4,4;2,1;handbreak;Toggle handbreak]"
				.."button[4,6;2,1;leave;Leave ship]"
		elseif dssssa_player.current_inv_tab == 4 then -- Ship-AI
			fs = fs
		else
			error("invalid dssssa_player.current_inv_tab: "..dssssa_player.current_inv_tab)
		end

	else
		-- only invlist
		fs = fs
			.."list[current_player;main;0.25,5;8,4;0]"
	end

	player:set_inventory_formspec(fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	minetest.log(formname)
	minetest.log(dump(fields))

	if fields.tabhdr then
		local tab = math.floor(tonumber(fields.tabhdr) or 0) or 0
		if tab >= 1 and tab <= 4 then
			dssssa_player.current_inv_tab = tab
			dssssa_player.set_inventory_formspec(player)
			minetest.after(0, minetest.show_formspec, player:get_player_name(), "inv", player:get_inventory_formspec())
		end
	end
end)
