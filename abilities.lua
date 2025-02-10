seugyssd.props = {}
seugyssd.props.move = {obj = {}, distance = {}}

seugyssd.register_use("move", function(player, itemstack)
  local name = player:get_player_name()
  local obj = seugyssd.props.move.obj[name]
  if not obj then
    local ray = seugyssd.get_pointed_surface(player, 30, true, false)
    if not ray then return end
    obj = ray.ref
  end
  if obj then
    local p, op = player:get_pos(), obj:get_pos()
    seugyssd.props.move.distance[name] = seugyssd.props.move.distance[name] or vector.distance(p, op)
    seugyssd.props.move.obj[name] = seugyssd.props.move.obj[name] or obj


    local look_pos = vector.add(p, vector.multiply(player:get_look_dir(), seugyssd.props.move.distance[name]))
    local dist = vector.distance(op, look_pos)

    local intended_vel = vector.multiply(vector.direction(op, look_pos), dist*2)
    local vel = obj:get_velocity()

    if not obj:is_player() then
      obj:add_velocity(vector.subtract(intended_vel, vel))
    else
      obj:add_velocity(vector.subtract(intended_vel, vector.multiply(vel, 0.5)))
    end

  --elseif ray.type == "node" then
  end
end, "hold", nil, "Move")

controls.register_on_release(function(player, key)
  if key ~= "LMB" then return end
  local witem = player:get_wielded_item()
  if witem:get_name() ~= "seugys_screwdriver:screwdriver" then return end
  seugyssd.props.move.distance[player:get_player_name()] = nil
  seugyssd.props.move.obj[player:get_player_name()] = nil
end)


seugyssd.register_use("seperate", function(player, itemstack)
  local ray = seugyssd.get_pointed_surface(player, 30, true, false)
  if not ray then return end
  local pos = ray.intersection_point

  local objs = core.get_objects_inside_radius(pos, 5)
  for _,obj in pairs(objs) do
    if obj:get_attach() then
      obj:set_detach()
    end
  end
  local objs = core.get_objects_inside_radius(pos, 5)
  for _,obj in pairs(objs) do
    if obj:get_children() then
      for _,child in pairs(obj:get_children()) do
        child:set_detach()
      end
    end
  end

end, "press", "seugys_screwdriver_screwdriver_seperate.png", "Detach")

seugyssd.register_use("spin", function(player, itemstack)
  local ray = seugyssd.get_pointed_surface(player, 30, true, false)
  if not ray then return end

  local mult = 1

  local control = player:get_player_control()
  if control.aux1 then
    mult = -1
  end

  local obj = ray.ref

  if obj then
    if obj:is_player() then
      obj:set_look_horizontal(obj:get_look_horizontal()+math.rad(2*mult))
    else
      local newyaw = obj:get_yaw()+math.rad(2*mult)
      obj:set_yaw(newyaw)
      obj:get_luaentity()._target_yaw = newyaw
    end
  end

  seugyssd.add_particle("obj", obj, {
    time = 0.01,
    amount = 1,
    texture = "seugys_screwdriver_screwdriver_particle.png^[colorize:#fb5:200",
    glow = 12,
    maxsize = 6,
    minexptime = 0.1,
    maxexptime = 1,
  })

end, "hold", "seugys_screwdriver_screwdriver_spin.png", "Spin")

function search_value(tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end

seugyssd.register_use("abm_speed", function(player, itemstack)
  local ray = seugyssd.get_pointed_surface(player, 30, true, false)
  if not ray then return end

  local abms = core.registered_abms



  if ray.type ~= "node" then return end

  local node = minetest.get_node_or_nil(ray.under)

  if not node then return end



  seugyssd.add_particle("node", ray.under, {
    time = 0.2,
    amount = 60,
    texture = "seugys_screwdriver_screwdriver_particle.png^[colorize:#88f:200",
    glow = 12,
    maxsize = 6,
    minexptime = 0.1,
    maxexptime = 1,
    maxvel = vector.new(0.1,0.1,0.1),
    minvel = vector.new(-0.1,-0.1,-0.1),
  })

  for _,abm in pairs(abms) do
    if search_value(abm.nodenames, node.name) then
      abm.action(ray.under, node, 0, 0)
    end
  end
  if core.registered_nodes[node.name].on_timer and core.get_node_timer(ray.under) then
    core.registered_nodes[node.name].on_timer(ray.under, core.get_node_timer(ray.under):get_elapsed())
  end


end, "press", "seugys_screwdriver_screwdriver_abm.png", "ABM Speed-up")

core.register_entity("seugys_screwdriver:entity", {
  physical = true,
  on_step = function(self)
    self.object:set_acceleration(vector.new(0,-9.81,0))
    self.object:set_velocity(vector.multiply(self.object:get_velocity(), vector.new(0.93,1,0.93)))
  end,
  on_activate = function(self, staticdata, dtime_s)
    self.object:set_properties(core.deserialize(staticdata) or {})
  end,
  get_staticdata = function(self)
    return core.serialize(self.object:get_properties())
  end,
})


seugyssd.register_use("copy_paste", function(player, itemstack)
  local ray = seugyssd.get_pointed_surface(player, 30, true, false)
  if not ray then return end

  local obj = ray.ref

  local props = {}

  if obj then
    seugyssd.add_particle("obj", obj, {
      time = 0.2,
      amount = 500,
      texture = "seugys_screwdriver_screwdriver_particle.png^[colorize:#88f:200",
      glow = 12,
      maxsize = 6,
      minexptime = 0.1,
      maxexptime = 1,
    })
    local objp = obj:get_properties()
    if obj:is_player() then
      props = objp
    else
      props = objp
    end

    objp.physical = true

    local moby = core.add_entity(ray.intersection_point, "seugys_screwdriver:entity")
    moby:set_properties(objp)

  end


end, "press", "seugys_screwdriver_screwdriver_copypaste.png", "Entity Clone")


seugyssd.register_use("incinerate", function(player, itemstack)
  local ray = seugyssd.get_pointed_surface(player, 30, true, false)
  if not ray then return end

  local obj = ray.ref

  local props = {}

  if obj then
    seugyssd.add_particle("obj", obj, {
      time = 0.2,
      amount = 500,
      maxacc = vector.new(0,1,0),
      texture = "seugys_screwdriver_screwdriver_particle.png^[colorize:#511:200",
      glow = 12,
      maxsize = 6,
      minexptime = 0.1,
      maxexptime = 1,
    })
    core.sound_play("seugys_screwdriver_incinerate", {pos = obj:get_pos(), max_hear_distance=16}, true)
    if obj:is_player() then
      obj:set_pos(vector.new(-1000,1000,-1000))
      obj:set_hp(0)
    else
      obj:set_hp(0)
      obj:remove()
    end
  end

end, "press", "seugys_screwdriver_screwdriver_incinerate.png", "Incinerate")


seugyssd.register_use("display_info", function(player, itemstack)
  local ray = seugyssd.get_pointed_surface(player, 30, true, false)
  if not ray then return end

  local obj = ray.ref

  local finalstring = {"_________________________________________"}

  if ray.type == "node" then
    local meta = core.get_meta(ray.under)


    table.insert(finalstring, "name: " .. minetest.get_node(ray.under).name)
    table.insert(finalstring, "description: " .. minetest.registered_nodes[minetest.get_node(ray.under).name].description)


    local metakeys = meta:get_keys()

    for _,key in pairs(metakeys) do
      table.insert(finalstring, tostring(key)..": "..meta:get_string(key))
    end
  end

  seugyssd.hud_text(player, "display_info", {
    text = table.concat(finalstring, "\n"),
    alignment = {x=1, y=1},
    position = {x=0, y=0},
    offset = {x=10, y=170},
    time_visible = 0.1,
  })


end, "hold", "seugys_screwdriver_screwdriver_info.png", "Display Info")
