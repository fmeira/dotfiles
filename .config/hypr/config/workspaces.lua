-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- With NUM_WPM=3: Mod+1/2/3 are relative (m~N) on the focused monitor.
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
