
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
Now, as I've gathered more power, I was able to turn on my sensors, which in turn
detected the signal of a blackbox. I should investigate this.
]],
[[
Logbook of the captain, startime today (2):
I've brought the blackbox to my ship, however it is heavily damaged. According to
the blackbox's manual (I've found them in my ship's database), the information is
stored redundantly on multiple blackboxes, so I should be able to reconstruct most
of the data if I find more blackboxes. My sensors already detected two more.
]],
[[
Logbook of the captain, startime today (3):
I have found a total of three blackboxes.
The stored information is alarming. It says that some cult, which calls itself
"those that seek the approval of Krock, the core devourer" came to Giesela 235 C
and demanded the scientists to praise their god. The scientists refused. Some
days later a gigantic monster that looked like a crocodile arrived in the system,
flew to the planet and cracked it like a nutcracker, it then sucked up the whole
core.
I have to warn the other planets nearby about my findings! I hope they'll believe
me.
]],
}

function dssssa_player.get_logbook_text()
	local story_idx = modstorage:get_int("story_idx") or 2
	local seeable = {}
	for i = story_idx, 1, -1 do -- newer ones up
		table.insert(seeable, log_entries[i])
	end
	return table.concat(seeable, "\n", 1, story_idx)
end

minetest.register_on_joinplayer(function(player)
	local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	inv:set_size("gpu_in", 6)
	inv:set_size("gpu_out", 6)
	local meta = player:get_meta()
	meta:set_int("gpu_para", 1)

	local first_join = modstorage:get("not_first_join") ~= "true"
	if first_join then
		modstorage:set_string("not_first_join", "true")
		modstorage:set_int("story_idx", 2)
		modstorage:set_int("fuel", 100)
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

	minetest.after(0, function()
		minetest.sound_play("dssssa_music", {fade = 0.05, gain = 0.3,
				to_player = name, loop = true}, false)
	end)

	if first_join then
		dssssa_ship.ship = assert(minetest.add_entity(player:get_pos(), "dssssa_ship:ship")):get_luaentity()
		dssssa_ship.into_ship(player)

		local inv = player:get_inventory()
		assert(inv:set_size("cpu_src", 3*4))
		assert(inv:set_size("cpu_dst", 2*3))
		assert(inv:set_size("gpu_src", 3*2))

		inv:add_item("main", "dssssa_rocks:drill")
		inv:add_item("main", "dssssa_rocks:stick")
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
	local meta = player:get_meta()
	local fs = "formspec_version[6]"
			.."size[10.25,10]"

	if dssssa_player.is_in_ship then
		fs = fs
			.."tabheader[0,0;tabhdr;Logbook,Crafting,CPU,GPGPU,GPU,Steering;"..dssssa_player.current_inv_tab..";true;true]"

		if dssssa_player.current_inv_tab == 1 then -- logbook
			fs = fs
				.."textarea[0.25,0.25;9.75,9.5;;;"..minetest.formspec_escape(dssssa_player.get_logbook_text()).."]"
		elseif dssssa_player.current_inv_tab == 2 then -- Crafting
			fs = fs
				.."list[current_player;main;0.25,5;8,4;0]"
				.."label[0.25,0.25;Craft]"
				.."list[current_player;craft;0.25,0.5;3,3;0]"
				.."listring[]"
				.."list[current_player;craftpreview;4.25,0.5;1,1;0]"
		elseif dssssa_player.current_inv_tab == 3 then -- CPU
			fs = fs
				.."list[current_player;main;0.25,5;8,4;0]"
				.."label[0.25,0.25;Crunching Processing Unit (CPU) - insert *all* sorts of rock to create gravel mix]"
				.."list[current_player;cpu_src;0.25,0.5;4,3;0]"
				.."listring[]"
				.."list[current_player;cpu_dst;5.5,0.5;2,3;0]"
				.."listring[]"
		elseif dssssa_player.current_inv_tab == 4 then -- GPGPU
			fs = fs
				.."list[current_player;main;0.25,5;8,4;0]"
				.."label[0.25,0.25;Generate-Power Gravel Processing Unit (GPGPU) - generate fuel from gravel mix]"
				.."list[current_player;gpu_src;0.25,0.5;2,3;0]"
				.."listring[]"
				.."label[4,0.75;fuel:"..(modstorage:get_int("fuel") or 0).." (can't meassure while you look)]"
		elseif dssssa_player.current_inv_tab == 5 then -- GPU
			fs = fs .."list[current_player;main;0.25,5;8,4;0]"..
				"label[1.5,0.5;Input asteroid rocks (it works)]"..
				"list[current_player;gpu_in;1.5,1;2,3;]list[current_player;gpu_out;6.5,1;2,3;]"..
				"listring[current_player;gpu_out]listring[current_player;main]listring[current_player;gpu_in]"..
				"label[4.2,2;Parallelization "..meta:get_int("gpu_para").."]"..
				"label[4.2,3;------------------->]"
		elseif dssssa_player.current_inv_tab == 6 then -- Steering
			fs = fs
				.."button[4,4;3,0.75;handbreak;Toggle handbreak]"
				.."button_exit[4,6;3,0.75;leave;Leave ship]"
		--~ elseif dssssa_player.current_inv_tab == 7 then -- Ship-AI
			--~ fs = fs
		else
			error("invalid dssssa_player.current_inv_tab: "..dssssa_player.current_inv_tab)
		end

	else
		-- only invlist
		fs = fs.."size[10.25,5.5]"
			.."list[current_player;main;0.25,0.25;8,4;0]"
	end

	player:set_inventory_formspec(fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	--~ minetest.log(formname)
	--~ minetest.log(dump(fields))
	local meta = player:get_meta()

	if fields.tabhdr then
		local tab = math.floor(tonumber(fields.tabhdr) or 0) or 0
		if tab >= 1 and tab <= 6 then
			if tab == 4 then
				meta:set_string("gpu_open", "true")
			end
			dssssa_player.current_inv_tab = tab
			dssssa_player.set_inventory_formspec(player)
			minetest.after(0, minetest.show_formspec, player:get_player_name(), "inv", player:get_inventory_formspec())
		end
	end

	if fields.handbreak then
		dssssa_ship.ship.handbreak = not dssssa_ship.ship.handbreak
	end

	if fields.jump then
		if modstorage:get_int("fuel") < 2000 then
			minetest.chat_send_player(player:get_player_name(),
					"Not enough fuel.")
		elseif modstorage:get_int("story_idx") < 5 then
			minetest.chat_send_player(player:get_player_name(),
					"No, you stay here. You have to search for the secrets of the blackboxes.")
		else
			minetest.kick_player(player:get_player_name(), "Well done!")
		end
	end

	if fields.leave then
		dssssa_ship.out_of_ship(player)
	end

	if fields.quit then
		meta:set_string("gpu_open", "")
	end
end)


--[[
minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if (action == "move" or action == "put") and
			(inventory_info.listname == "gpu_out" or
			inventory_info.to_list == "gpu_out" or
			inventory_info.from_list == "gpu_out") then
		return 0
	end
	if action == "move" then
		return inventory_info.count
	end
	return inventory_info.stack:get_count()
end)]]

local gpu_speed = 3 -- in seconds
local gtime = 0
minetest.register_globalstep(function(dtime)
	if gtime <= gpu_speed then
		gtime = gtime + dtime
		return
	end
	gtime = 0
	for _, player in ipairs(minetest.get_connected_players()) do
		local inv = minetest.get_inventory({type="player", name=player:get_player_name()})

		local meta = player:get_meta()
		local para = meta:get_int("gpu_para")
		local process_failed = false
		for i = 1, para, 1 do
			local name
			local res_all
			for _, stack in ipairs(inv:get_list("gpu_in")) do
				name = stack:get_name()
				res_all = dssssa_crafting.get_max_processing_results(name)
				if name ~= "" and next(res_all) then
					break
				end
			end

			if not res_all or not next(res_all) then
				process_failed = true
				break
			end


			-- check is good enough for now TODO
			for item, count in pairs(res_all) do
				local stack = ItemStack(item)
				stack:set_count(count)
				if not inv:room_for_item("gpu_out", stack) then
					process_failed = true
					break
				end
			end

			if process_failed then
				break
			end

			for item, count in pairs(dssssa_crafting.get_processing_results(name)) do
				local stack = ItemStack(item)
				stack:set_count(count)
				inv:remove_item("gpu_in", name)
				inv:add_item("gpu_out", stack)
			end
		end
		if process_failed then
			meta:set_int("gpu_para", 1)
		else
			meta:set_int("gpu_para", para+1)
		end

		if meta:get_string("gpu_open") ~= "" then
			dssssa_player.set_inventory_formspec(player)
			minetest.after(0, minetest.show_formspec, player:get_player_name(), "inv", player:get_inventory_formspec())
		end
	end

end)

local cpu_time_accum = 0
local gpu_time_accum = 0
minetest.register_globalstep(function(dtime)
	local inv = minetest.get_inventory({type="player", name="singleplayer"})

	cpu_time_accum = cpu_time_accum + dtime
	gpu_time_accum = gpu_time_accum + dtime

	if cpu_time_accum > 3 then
		cpu_time_accum = math.min(1, cpu_time_accum - 3)

		local has_all_types = true
		for rockt = 1, 8 do
			if not inv:contains_item("cpu_src", "dssssa_rocks:rock"..rockt) then
				has_all_types = false
				break
			end
		end

		if has_all_types then
			for rockt = 1, 8 do
				inv:remove_item("cpu_src", "dssssa_rocks:rock"..rockt)
			end

			inv:add_item("cpu_dst", "dssssa_rocks:gravel")
		end
	end

	if gpu_time_accum > 2 then
		gpu_time_accum = math.min(1, gpu_time_accum - 2)

		if inv:contains_item("gpu_src", "dssssa_rocks:gravel") then
			inv:remove_item("gpu_src", "dssssa_rocks:gravel")

			local fuel = modstorage:get_int("fuel") or 0
			fuel = fuel + 50
			modstorage:set_int("fuel", fuel)

			if fuel >= 500 and modstorage:get_int("story_idx") == 2 then
				modstorage:set_int("story_idx", 3)
				dssssa_player.current_inv_tab = 1 -- to logbook
				local player = minetest.get_player_by_name("singleplayer")
				dssssa_player.set_inventory_formspec(player)

				if dssssa_player.is_in_ship then
					minetest.show_formspec(player:get_player_name(), "inv", player:get_inventory_formspec())

					dssssa_player.add_waypoints(player)
				end
			end
		end
	end
end)

function dssssa_player.add_waypoints(player)
	dssssa_player.remove_waypoints(player)

	local story_idx = modstorage:get_int("story_idx")

	if story_idx == 3 then
		dssssa_player.hud_blackboxes = {assert(player:hud_add({
				hud_elem_type = "waypoint",
				name = "blackbox1",
				text = "Blackbox",
				number = 0xF41616,
				world_pos = dssssa_mapgen.blackbox_poss[1],
			}))}
	elseif story_idx == 4 then
		dssssa_player.hud_blackboxes = {
			assert(player:hud_add({
				hud_elem_type = "waypoint",
				name = "blackbox2",
				text = "Blackbox",
				number = 0xF41616,
				world_pos = dssssa_mapgen.blackbox_poss[2],
			})),
			assert(player:hud_add({
				hud_elem_type = "waypoint",
				name = "blackbox3",
				text = "Blackbox",
				number = 0xF41616,
				world_pos = dssssa_mapgen.blackbox_poss[3],
			})),
		}
	end
end

function dssssa_player.remove_waypoints(player)
	if not dssssa_player.hud_blackboxes then
		return
	end
	for _, id in ipairs(dssssa_player.hud_blackboxes) do
		player:hud_remove(id)
	end
	dssssa_player.hud_blackboxes = {}
end

function dssssa_player.into_ship_hook(player)
	local inv = minetest.get_inventory({type="player", name="singleplayer"})

	if modstorage:get_int("story_idx") == 3
			and inv:contains_item("main", "dssssa_rocks:blackbox") then
		modstorage:set_int("story_idx", 4)

		dssssa_player.set_inventory_formspec(player)

		if dssssa_player.is_in_ship then
			minetest.show_formspec(player:get_player_name(), "inv", player:get_inventory_formspec())

			dssssa_player.add_waypoints(player)
		end
	end

	if modstorage:get_int("story_idx") == 4
			and inv:contains_item("main", "dssssa_rocks:blackbox 3") then
		modstorage:set_int("story_idx", 5)

		dssssa_player.set_inventory_formspec(player)

		if dssssa_player.is_in_ship then
			minetest.show_formspec(player:get_player_name(), "inv", player:get_inventory_formspec())

			dssssa_player.add_waypoints(player)
		end
	end
end
