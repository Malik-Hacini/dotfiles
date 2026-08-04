-- Extra autostart processes.
-- o.launch_on_start("my-service")

local zathura_classes = {
  ["org.pwmt.zathura"] = true,
  zathura = true,
}

local function is_zathura(window)
  local class = (window.class or window.initial_class or ""):lower()
  return zathura_classes[class] == true
end

local function is_zathura_group(group)
  local members = group.members or {}
  if #members == 0 then
    return false
  end

  for _, member in ipairs(members) do
    if not is_zathura(member) then
      return false
    end
  end

  return true
end

hl.on("window.open", function(window)
  if not is_zathura(window) or not window.workspace then
    return
  end

  local target
  for _, group in ipairs(window.workspace:get_groups()) do
    if is_zathura_group(group) then
      target = group
      break
    end
  end

  if target then
    if window.group ~= target then
      if window.group then
        window.group:remove(window)
      end
      target:add(window)
    end
    return
  end

  if window.group then
    window.group:remove(window)
  end
  hl.dispatch(hl.dsp.group.toggle({ window = window }))
end)
