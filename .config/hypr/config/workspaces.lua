-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- With NUM_WPM=3: Mod+1/2/3 are relative (m~N) on the focused monitor.
-- On the laptop alone, Mod+4/5/6 reach workspaces 4-6 on that screen.
-- At work, the ultrawide also gets workspaces 7-9, on Mod+4/5/6.
-- Only one rule per workspace ID is kept (later overwrites earlier), so do not
-- duplicate 4–6 for home + work. Point MONITOR2 at the current primary external
-- in variables.lua (Lenovo at work, home-left Dell at home).

hl.workspace_rule({ workspace = "name:gaming", monitor = PRIMARY_MONITOR, default = true })
hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = MONITOR1, default = true, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = MONITOR1, default = true, persistent = true })

-- Primary external (MONITOR2): work ultrawide or home left Dell
hl.workspace_rule({ workspace = "4", monitor = MONITOR2, default = true, persistent = true })
hl.workspace_rule({ workspace = "5", monitor = MONITOR2, default = true, persistent = true })
hl.workspace_rule({ workspace = "6", monitor = MONITOR2, default = true, persistent = true })

-- Home right Dell (ignored when not connected)
hl.workspace_rule({ workspace = "7", monitor = MONITOR3, default = true, persistent = true })
hl.workspace_rule({ workspace = "8", monitor = MONITOR3, default = true, persistent = true })
hl.workspace_rule({ workspace = "9", monitor = MONITOR3, default = true, persistent = true })

-- Laptop alone: workspaces 4-6 join 1-3 on the laptop, with Super+4/5/6.
-- Work: the Lenovo keeps 4-6 and also gets 7-9, on Super+4/5/6.
-- Home: 4-6 stay on the left Dell, 7-9 on the right, and Super+4/5/6 are not used.
local function digit_code(d)
    return "code:" .. (9 + d)
end

local SOLO_KEYS = { 4, 5, 6 }
local WORK_EXTRA = { 7, 8, 9 }

local function connected_monitors()
    local ok, monitors = pcall(hl.get_monitors)
    if not ok or not monitors then
        return 0
    end
    local count = 0
    for _, monitor in ipairs(monitors) do
        if not monitor.is_mirror then
            count = count + 1
        end
    end
    return count
end

local function work_ultrawide_connected()
    local ok, monitors = pcall(hl.get_monitors)
    if not ok or not monitors then
        return false
    end
    for _, monitor in ipairs(monitors) do
        if not monitor.is_mirror then
            local desc = tostring(monitor.description or "")
            local serial = tostring(monitor.serial or "")
            if desc:find("P40w-20", 1, true) or desc:find("V90E1NK8", 1, true) or serial:find("V90E1NK8", 1, true) then
                return true
            end
        end
    end
    return false
end

local function pin_workspaces(ids, monitor)
    for _, id in ipairs(ids) do
        hl.workspace_rule({
            workspace = tostring(id),
            monitor = monitor,
            default = true,
            persistent = true,
        })
    end
end

local function bind_key(keys, dispatcher)
    pcall(function()
        hl.unbind(keys)
    end)
    return hl.bind(keys, dispatcher)
end

local function apply_workspace_layout()
    for _, key in ipairs(SOLO_KEYS) do
        local code = digit_code(key)
        pcall(function() hl.unbind("SUPER + " .. code) end)
        pcall(function() hl.unbind("SUPER + SHIFT + " .. code) end)
        pcall(function() hl.unbind("SUPER + SHIFT + CONTROL + " .. code) end)
    end

    local function bind_numbered(keys, workspaces)
        for index, key in ipairs(keys) do
            local workspace = tostring(workspaces[index])
            local code = digit_code(key)
            bind_key("SUPER + " .. code, hl.dsp.focus({ workspace = workspace }))
            bind_key("SUPER + SHIFT + " .. code, hl.dsp.window.move({ workspace = workspace, follow = false }))
            bind_key("SUPER + SHIFT + CONTROL + " .. code, hl.dsp.window.move({ workspace = workspace }))
        end
    end

    if connected_monitors() == 1 then
        pin_workspaces(SOLO_KEYS, MONITOR1)
        pin_workspaces(WORK_EXTRA, MONITOR3)
        bind_numbered(SOLO_KEYS, SOLO_KEYS)
        return
    end

    if connected_monitors() > 1 and work_ultrawide_connected() then
        pin_workspaces({ 4, 5, 6, 7, 8, 9 }, WORK_EXT)
        bind_numbered(SOLO_KEYS, WORK_EXTRA)
        return
    end

    if connected_monitors() > 1 then
        pin_workspaces(SOLO_KEYS, MONITOR2)
        pin_workspaces(WORK_EXTRA, MONITOR3)
    end
end

apply_workspace_layout()
hl.on("hyprland.start", apply_workspace_layout)
hl.on("monitor.added", function()
    hl.timer(apply_workspace_layout, { timeout = 200, type = "oneshot" })
end)
hl.on("monitor.removed", function()
    hl.timer(apply_workspace_layout, { timeout = 200, type = "oneshot" })
end)
