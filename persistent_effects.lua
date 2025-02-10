persistent_api = {
  effects = {}
}

function persistent_api.add_persistent_effect(def)
  persistent_api.effects[def.object] = persistent_api.effects[def.object] or {}
  persistent_api.effects[def.object][def.name] = {duration = minetest.get_gametime()+def.duration, persistence = {def.persistence, 0}, effect = def.effect}
end

local lsls = false

minetest.register_globalstep(function(dtime)
  for object,defs in pairs(persistent_api.effects) do
    for indexx,def in pairs(defs) do
      if def.duration < minetest.get_gametime() or not object or object and not object:get_pos() then
        persistent_api.effects[object][indexx] = nil
      else
        def.persistence[2] = def.persistence[2] + dtime
        if def.persistence[2] > def.persistence[1] then
          def.effect(object)
          def.persistence[2] = 0
        end
      end
    end
  end
end)
