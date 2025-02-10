seugyssd.uses = {}
seugyssd.current_hud = {}

function seugyssd.register_use(name, func, actype, texture, description)
  if not texture then texture = "seugys_screwdriver_screwdriver.png" end

  seugyssd.uses[name] = {description = description, texture = texture, func = func, activation_type = actype}
end

function seugyssd.get_pointed_surface(player, reach, objects, liquids)
  local dir = player:get_look_dir()
  local pos = vector.add(player:get_pos(), vector.new(0,player:get_properties().eye_height,0))
  local raycast = core.raycast(pos, vector.add(pos, vector.multiply(dir, reach)), objects, liquids, true)
  for pointed_thing in raycast do
    if not pointed_thing.ref or pointed_thing.ref and not (pointed_thing.ref:is_player() and pointed_thing.ref:get_player_name() == player:get_player_name()) then
      return pointed_thing
    end
  end
end

local function get_use(stack)
  local meta = stack:get_meta()
  local use = meta:get_string("use")
  if use == "" then meta:set_string("use", "move"); use = "move" end
  return use
end

local function set_use(player, stack, use)
  seugyssd.hud_text(player, "switch_screwdriver_uses", {
    text = seugyssd.uses[use].description,
    position = {x=0.5, y=1},
    offset = {x=0, y=-110},
    expiretime = 1,
  })
  local meta = stack:get_meta()
  meta:set_string("use", use)
  meta:set_string("inventory_image", seugyssd.uses[use].texture)
end

core.register_tool("seugys_screwdriver:screwdriver", {
  description = "Seugy's Screwdriver",
  inventory_image = "seugys_screwdriver_screwdriver.png",
  range = 0,
  on_use = function(itemstack, user, pointed_thing)
    return
  end,
  on_secondary_use = function(itemstack, user, pointed_thing)
    local cycle
    local cuse = get_use(itemstack)
    core.sound_play("seugys_screwdriver_end", {object = user, max_hear_distance=7}, true)

    for use,def in pairs(seugyssd.uses) do
      if cycle then
        set_use(user, itemstack, use)
        return itemstack
      end
      if use == cuse then cycle = true end
    end
    if cycle then
      for use,def in pairs(seugyssd.uses) do
        set_use(user, itemstack, use)
        return itemstack
      end
    end
  end,
})

seugyssd.sounds = {loop = {}}





controls.register_on_press(function(player, key)
  local witem = player:get_wielded_item()
  if witem:get_name() ~= "seugys_screwdriver:screwdriver" then return end
  if key == "RMB" then core.sound_play("seugys_screwdriver_button_down", {object = player, max_hear_distance=7}, true); return end
  if key ~= "LMB" then return end
  if seugyssd.uses[get_use(witem)].activation_type == "press" then
    core.sound_play("seugys_screwdriver_quick", {object = player, max_hear_distance=7}, true)
  else
    core.sound_play("seugys_screwdriver_begin", {object = player, max_hear_distance=7}, true)
    seugyssd.sounds.loop[player:get_player_name()] = core.sound_play("seugys_screwdriver_loop", {object = player, max_hear_distance=7, loop = true, pitch = math.random(10)/50+0.9})
  end
  seugyssd.uses[get_use(witem)].func(player, witem)
end)

controls.register_on_hold(function(player, key)
  if key ~= "LMB" then return end
  local witem = player:get_wielded_item()
  if witem:get_name() ~= "seugys_screwdriver:screwdriver" then
    if seugyssd.sounds.loop[player:get_player_name()] then
      core.sound_stop(seugyssd.sounds.loop[player:get_player_name()])
      seugyssd.sounds.loop[player:get_player_name()] = nil
      core.sound_play("seugys_screwdriver_end", {object = player, max_hear_distance=7}, true)
    end
    return
  end
  if seugyssd.uses[get_use(witem)].activation_type ~= "hold" then return end
  seugyssd.uses[get_use(witem)].func(player, witem)
end)

controls.register_on_release(function(player, key)
  local witem = player:get_wielded_item()
  if key == "RMB" and witem:get_name() == "seugys_screwdriver:screwdriver" then core.sound_play("seugys_screwdriver_button_up", {object = player, max_hear_distance=7}, true); return end
  if key ~= "LMB" then return end

  if seugyssd.sounds.loop[player:get_player_name()] then core.sound_stop(seugyssd.sounds.loop[player:get_player_name()]); seugyssd.sounds.loop[player:get_player_name()] = nil end

  if witem:get_name() == "seugys_screwdriver:screwdriver" then
    if seugyssd.uses[get_use(witem)].activation_type ~= "hold" then return end
    core.sound_play("seugys_screwdriver_end", {object = player, max_hear_distance=7}, true)
  end
end)


function seugyssd.add_particle(type, target, def)

  if not target then return end

  local pos1, pos2
  if type == "node" then
    pos1 = vector.add(target, vector.new(-0.59,-0.59,-0.59))
    pos2 = vector.add(target, vector.new(0.59,0.59,0.59))
  elseif type == "obj" then
    local c = target:get_properties().collisionbox
    pos1 = vector.add(target:get_pos(), vector.new(c[1], c[2], c[3]))
    pos2 = vector.add(target:get_pos(), vector.new(c[4], c[5], c[6]))
  elseif type == "radius" then
  elseif type == "area" then
  end

  core.add_particlespawner({
    minpos = def.minpos or pos1,
    maxpos = def.maxpos or pos2,
    amount = def.amount or 10,
    time = def.time or 1,
    collisiondetection = def.collisiondetection,
    collision_removal = def.collision_removal,
    object_collision = def.object_collision,
    attached = def.attached,
    vertical = def.vertical,
    texture = def.texture or "seugys_screwdriver_screwdriver_particle.png",
    playername = def.playername,
    animation = def.animation,
    glow = def.glow,
    node = def.node,
    node_tile = def.node_tile,
    minvel = def.minvel or vector.zero(),
    maxvel = def.maxvel or vector.zero(),
    minacc = def.minacc or vector.zero(),
    maxacc = def.maxacc or vector.zero(),
    minexptime = def.minexptime or 1,
    maxexptime = def.maxexptime or 3,
    minsize = def.minsize or 1,
    maxsize = def.maxsize or 3,
  })
end

function seugyssd.hud_text(player, name, def)
  local hudd = {
    type = "text",
    position = {x=0.5,y=0.5},
    scale = {x = 1, y = 1},
    text = "Change this",
    number = 0xffffff,
    time_visible = 1,
  }
  for key,value in pairs(def) do
    hudd[key] = value
  end
  local time_visible = def.time_visible or hudd.time_visible
  local chud = seugyssd.current_hud[player:get_player_name()] or {}
  seugyssd.current_hud[player:get_player_name()] = chud or {}
  if not chud[name] then
    chud[name] = {}
    seugyssd.current_hud[player:get_player_name()][name] = {}
  end
  if chud[name].id then player:hud_remove(chud[name].id) end
  seugyssd.current_hud[player:get_player_name()][name].id = player:hud_add(hudd)
  seugyssd.current_hud[player:get_player_name()][name].expiretime = time_visible
end

core.register_globalstep(function(dtime)
  for name,huds in pairs(seugyssd.current_hud) do
    local player = minetest.get_player_by_name(name)
    for nameid,hud in pairs(huds) do
      if hud.expiretime <= 0 and player then
        player:hud_remove(hud.id)
        huds[nameid] = nil
      else
        hud.expiretime = hud.expiretime - dtime
      end
    end
  end
end)
