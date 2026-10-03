-- Hyprland default apps

TERMINAL     = "kitty"
FILE_MANAGER = "dolphin"
BROWSER      = "firefox"
EDITOR       = "gnome-text-editor --new-window"
CALCULATOR   = "gnome-calculator"

-- Monitors — prefer desc: so workspace rules survive DP-N renames across docks.
-- Switch sites with: hypr-place home|work
-- HOME_LEFT / WORK_EXT must be defined before MONITOR2 uses them.
HOME_LEFT = "desc:Dell Inc. DELL U2421E DH3QS83" -- home left Dell
WORK_EXT  = "desc:Lenovo Group Limited P40w-20 V90E1NK8" -- work ultrawide

MONITOR1 = "eDP-1" -- laptop
MONITOR2 = HOME_LEFT
MONITOR3 = "desc:Dell Inc. DELL U2421E 8LNC5H3" -- home right
PRIMARY_MONITOR = MONITOR1

-- Workspaces
NUM_WPM = 3 -- Number of workspaces per monitor (Max 10)
