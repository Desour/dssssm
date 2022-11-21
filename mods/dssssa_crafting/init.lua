-- item definition 


minetest.register_craftitem("dssssa_crafting:metal", {
	description = "Metal",
	inventory_image = "dssssa_crafting_metal.png",
})

minetest.register_craftitem("dssssa_crafting:nonmetal", {
	description = "Nonmetal",
	inventory_image = "dssssa_crafting_nonmetal.png",
})

minetest.register_craftitem("dssssa_crafting:xenithium", {
	description = "Xenithium",
	inventory_image = "dssssa_crafting_xenithium.png",
})

-- processing api

dssssa_crafting = {}

-- not globally available for now
local processing_results = {}
local processing_results_group = {}
--local gpu_speed = 3 -- in seconds 

processing_results_group["rawrock"] = {
	{name = "dssssa_crafting:metal", chance = 0.2},
	{name = "dssssa_crafting:nonmetal", chance = 0.3},
	{name = "dssssa_crafting:xenithium", chance = 0.1}
}

function dssssa_crafting.get_processing_results(name)
	local res = processing_results[name]
	if not res then
		for group, r in pairs(processing_results_group) do
			if minetest.get_item_group(name, group) > 0 then
				res = r
				break
			end
		end
	end
	
	local ret = {}
	if not res then
		return ret
	end
	
	for _, t in ipairs(res) do
		if math.random() >= t.chance then
			if not ret[t.name] then
				ret[t.name] = 0
			end
			if t.count then
				ret[t.name] = ret[t.name] + t.count
			else
				ret[t.name] = ret[t.name] + 1
			end
		end
	end
	return ret
end

-- used to check if it fits into the output inv
function dssssa_crafting.get_max_processing_results(name)
	local res = processing_results[name]
	if not res then
		for group, r in pairs(processing_results_group) do
			if minetest.get_item_group(name, group) > 0 then
				res = r
				break
			end
		end
	end
	
	local ret = {}
	if not res then
		return ret
	end
	
	for _, t in ipairs(res) do
		if not ret[t.name] then
			ret[t.name] = 0
		end
		if t.count then
			ret[t.name] = ret[t.name] + t.count
		else
			ret[t.name] = ret[t.name] + 1
		end
	end
	
	return ret
end

--[[

-- formspec

-- this is temporary here (TODO)

local function get_player_fromspec(tab, player)
	local meta = player:get_meta()

	if tab == 1 then
		return "size[8,7.5]list[current_player;main;0,3.5;8,4;]"..
			"list[current_player;craft;3,0;3,3;]listring[]list[current_player;craftpreview;7,1;1,1;]"..
			"tabheader[0,0;playinvtab;CPU,GPU,AI,Status;"..tab..";true;true>]"
	elseif tab == 2 then
		return "size[8,7.5]list[current_player;main;0,3.5;8,4;]"..
			"list[current_player;gpu_in;1,0;2,3;]list[current_player;gpu_out;5,0;2,3;]"..
			"listring[current_player;gpu_out]listring[current_player;main]listring[current_player;gpu_in]"..
			"label[3.2,0;Parallelization "..meta:get_int("gpu_para").."]"..
			"label[3.2,1;------------------->]"..
			"tabheader[0,0;playinvtab;CPU,GPU,AI,Status;"..tab..";true;true>]"
	elseif tab == 3 then
		return "size[8,7.5]"..
			"tabheader[0,0;playinvtab;CPU,GPU,AI,Status;"..tab..";true;true>]"
	elseif tab == 4 then
		return "size[8,7.5]"..
			"tabheader[0,0;playinvtab;CPU,GPU,AI,Status;"..tab..";true;true>]"
	end
	
	return ""
end

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
	
end)

minetest.register_on_joinplayer(function(player)
	local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	inv:set_size("gpu_in", 6)
	inv:set_size("gpu_out", 6)
	local meta = player:get_meta()
	meta:set_int("gpu_para", 1)
	player:set_inventory_formspec(get_player_fromspec(1, player))
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" or not fields.playinvtab then
		return
	end
	local tab = tonumber(fields.playinvtab)
	player:set_inventory_formspec(get_player_fromspec(tab, player))
end)


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
				inv:add_item("gpu_out", stack)
			end
		end
		if process_failed then
			meta:set_int("gpu_para", 1)
		else
			meta:set_int("gpu_para", para+1)
		end
	end
	
end)


]]






