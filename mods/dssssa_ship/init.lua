
local max_speed = 30

dssssa_ship = {}

function dssssa_ship.into_ship(player)
	local self = dssssa_ship.ship

	if not self then
		return false
	end

	if self.driver_name then
		return false
	end

	self.driver_name = player:get_player_name()

	-- attach the driver
	player:set_attach(self.object, "", vector.zero(), vector.zero())
	player:set_eye_offset(vector.new(0, 50, -40), vector.new(0, 30, 0))
	dssssa_player.is_in_ship = true

	dssssa_player.current_inv_tab = 1
	dssssa_player.set_inventory_formspec(player)

	local hud_flags = player:hud_get_flags()
	hud_flags.wielditem = false
	player:hud_set_flags(hud_flags)

	dssssa_player.add_waypoints(player)

	return true
end

function dssssa_ship.out_of_ship(player)
	local self = dssssa_ship.ship

	if not self then
		return false
	end

	if not self.driver_name then
		return false
	end

	if self.object:get_velocity():length() > 2 then
		minetest.chat_send_player(player:get_player_name(),
				"The doors won't open at these speeds (thanks to the ship manufacturer's suicide-prevention technology (TM)).")
		return false
	end

	self.driver_name = nil

	-- detach the driver
	player:set_detach()
	player:set_eye_offset(vector.new(0, 0, 0), vector.new(0, 0, 0))
	dssssa_player.is_in_ship = false

	dssssa_player.current_inv_tab = 1
	dssssa_player.set_inventory_formspec(player)

	local hud_flags = player:hud_get_flags()
	hud_flags.wielditem = true
	player:hud_set_flags(hud_flags)

	dssssa_player.remove_waypoints(player)

	return true
end

minetest.register_entity("dssssa_ship:ship", {
	initial_properties = {
		physical = true,
		collide_with_objects = true,
		collisionbox = {-2, -2, -2, 2, 2, 2},
		selectionbox = {-2, -2, -2, 2, 2, 2},
		visual = "mesh",
		mesh = "dssssa_ship.b3d",
		textures = {"dssssa_ship.png"},
	},

	driver_name = nil,
	handbreak = false,

	on_activate = function(self)
		dssssa_ship.ship = self
		self.object:set_armor_groups({immortal=1})
		self.handbreak = true
	end,

	on_step = function(self, dtime)
		dssssa_ship.ship = self -- >:)

		local driver = nil
		if self.driver_name then
			driver = minetest.get_player_by_name(self.driver_name)
			if driver and not minetest.is_player(driver) then
				driver = nil
			end
		end

		local rot
		if driver then
			rot = vector.new(-driver:get_look_vertical(), driver:get_look_horizontal(), 0)
			self.object:set_rotation(rot)
		else
			rot = self.object:get_rotation()
		end

		local oldvel = self.object:get_velocity()
		local vel = oldvel:copy()

		-- thrusters
		local ctrl = driver and driver:get_player_control() or {}
		local thrust = vector.zero()
		if ctrl.up then
			thrust = thrust + vector.new(0, 0, 10)
		end
		if ctrl.down then
			thrust = thrust + vector.new(0, 0, -5)
		end
		if ctrl.right then
			thrust = thrust + vector.new(1, 0, 0)
		end
		if ctrl.left then
			thrust = thrust + vector.new(-1, 0, 0)
		end
		if ctrl.jump then
			thrust = thrust + vector.new(0, 1, 0)
		end
		if ctrl.sneak then
			thrust = thrust + vector.new(0, -1, 0)
		end
		do
			local delvec = vector.rotate(thrust * dtime, rot)
			vel = vel + delvec
		end

		-- handbreak
		if self.handbreak then
			vel = vel * 0.9
			if vel:length() < 0.1 then
				vel = vector.zero()
			end
		end

		-- max speed
		do
			local speed = vel:length()
			if speed > max_speed then
				vel = vel * (max_speed / speed)
			end
		end

		if vel ~= oldvel then
			self.object:set_velocity(vel)
		end
	end,

	on_rightclick = function(self, clicker)
		if not clicker or not minetest.is_player(clicker) then
			return
		end

		dssssa_ship.into_ship(clicker)
	end,
})
