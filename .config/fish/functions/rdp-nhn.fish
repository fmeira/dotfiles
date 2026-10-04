#function rdp-nhn
    # 1. Strip ONLY the broken resolution specs, leaving all gateway/security tokens alone
#    sed -i '/desktopwidth/d; /desktopheight/d; /screen mode id/d' $argv

    # 2. Open it in a clean full-screen surface without forcing extra resolution arguments
#    sdl-freerdp3 $argv /kbd:layout:Icelandic /f
#end

#function rdp-nhn
    # 1. Clean the hardcoded tiny resolution limits out of the newest RDP file
#    sed -i '/desktopwidth/d; /desktopheight/d; /screen mode id/d' $argv[1]

    # 2. Fire it up using xfreerdp3, requesting a crisp native size target
    #xfreerdp3 $argv[1] /kbd:layout:Icelandic /size:1920x1440 /smart-sizing
#    sdl-freerdp3 $argv[1] -gfx /gdi:sw /size:1920x1080 /scale:100 /scale-desktop:100

    # 3. Teardown: Wait for the session to close, then safely delete the file
#    echo "RDP session closed. Cleaning up temporary token file..."
#    rm -f $argv
#end

#function rdp-nhn
#    set -l rdp $argv[1]
#    if test -z "$rdp"; or not test -f "$rdp"
#        echo "usage: rdp-nhn file.rdp" >&2
#        return 1
#    end

    # Drop the file's own size so /size + /smart-sizing own the framebuffer.
    # Same combination that worked under Sway. /p skips the empty password prompt.
#    sed -i '/^desktopwidth:/d; /^desktopheight:/d; /^screen mode id:/d' -- "$rdp"
    # SDL shows the PSM desktop ("Preparing Windows") and never the RemoteApp.
    # xfreerdp opens ||PSMInitSession directly. All gfx codecs off so the page
    # is bitmap updates; the X11 client drops gfx surface redraws.
#    xfreerdp3 "$rdp" /p /kbd:layout:Icelandic /size:1920x1440 /smart-sizing /gfx:RFX:off,AVC444:off,AVC420:off,progressive:off /network:modem
#    set -l code $status

#    if test $code -eq 0
#        rm -f -- "$rdp"
#        echo "RDP session closed. Removed token file."#
    #else
#        echo "RDP exited with status $code. Left token file in place." >&2
#    end
#    return $code
#end

function rdp-nhn
    set -l rdp $argv[1]
    if test -z "$rdp"; or not test -f "$rdp"
        echo "usage: rdp-nhn file.rdp" >&2
        return 1
    end

    set -l xephyr_bin (command -v Xephyr)
    if test -z "$xephyr_bin"; and test -x $HOME/.local/bin/Xephyr
        set xephyr_bin $HOME/.local/bin/Xephyr
    end
    if test -z "$xephyr_bin"
        echo "rdp-nhn: Xephyr is missing. Install it with: sudo pacman -S xorg-server-xephyr" >&2
        return 1
    end

    # Laptop is scale 2 and X11 is drawn 1:1, so this appears at about
    # 1800x1050. Same screen at home and at work. xfreerdp talks only to Xephyr.
    set -l width 3600
    set -l height 2100
    set -l scale 100

    set -l display_num 20
    while test -S /tmp/.X11-unix/X$display_num
        set display_num (math $display_num + 1)
    end

    echo "rdp-nhn: Xephyr :$display_num  $width x $height on the laptop"

    # A transient service, so kitty does not swallow the window onto the
    # terminal's screen. xkbcomp can take a few seconds before the display exists.
    # -ac: this server only exists for the local client.
    # -no-host-grab: leave Hyprland's keyboard grabs alone.
    set -l unit rdp-nhn-$display_num
    : >/tmp/xephyr-rdp.log
    systemd-run --user --collect --no-block --unit=$unit \
        --property=StandardOutput=append:/tmp/xephyr-rdp.log \
        --property=StandardError=append:/tmp/xephyr-rdp.log \
        $xephyr_bin :$display_num -screen $width"x"$height -no-host-grab -ac -br -title Splunk-RDP

    set -l xephyr_pid ""
    set -l ready 0
    for i in (seq 100)
        set xephyr_pid (systemctl --user show -p MainPID --value $unit.service 2>/dev/null)
        if test -S /tmp/.X11-unix/X$display_num
            and test -n "$xephyr_pid"
            and test "$xephyr_pid" != "0"
            and kill -0 $xephyr_pid 2>/dev/null
            set ready 1
            break
        end
        sleep 0.1
    end
    if test $ready -eq 0
        echo "rdp-nhn: Xephyr did not start. See /tmp/xephyr-rdp.log" >&2
        systemctl --user stop $unit.service 2>/dev/null
        return 1
    end
    sleep 0.2

    # FreeRDP's clipboard is the Xephyr one. This copies text both ways
    # with the desktop clipboard. Started before DISPLAY changes, so it
    # still sees the Wayland clipboard.
    set -l clip_pid 0
    if test -x $HOME/.local/bin/rdp-clip-bridge
        $HOME/.local/bin/rdp-clip-bridge :$display_num >/tmp/rdp-clip.log 2>&1 &
        set clip_pid $last_pid
    end

    grep -vE "screen|width|height|geometry|smart sizing|desktopwidth|desktopheight|keyboard|winposstr" -- "$rdp" > /tmp/temp_target.rdp
    echo "desktopwidth:i:$width" >> /tmp/temp_target.rdp
    echo "desktopheight:i:$height" >> /tmp/temp_target.rdp
    # Open the remote window across the whole screen. Maximizing it later
    # grows the window into an area that stays blank.
    echo "winposstr:s:0,1,0,0,$width,$height" >> /tmp/temp_target.rdp
    echo "smart sizing:i:1" >> /tmp/temp_target.rdp
    echo "use multimon:i:0" >> /tmp/temp_target.rdp
    echo "desktopscalefactor:i:$scale" >> /tmp/temp_target.rdp

    set -lx DISPLAY :$display_num
    set -lx LIBVA_DRIVER_NAME none
    if set -q FREERDP_GFX_CAPS
        set -e FREERDP_GFX_CAPS
    end

    # /p: the token has no password. Without this, xfreerdp waits at
    # "Password:" and the Xephyr window covers the terminal.
    # -disp: do not tell the server about the second monitor, or it
    # repositions the window off-screen after you move it.
    xfreerdp3 /tmp/temp_target.rdp /p /gdi:sw /network:lan /relax-order-checks /kbd:layout:0x0000040F /size:$width"x"$height /scale:$scale /scale-desktop:$scale /smart-sizing -disp /t:"Splunk-RDP"
    set -l code $status

    if test $clip_pid -gt 0
        kill $clip_pid 2>/dev/null
    end
    systemctl --user stop $unit.service 2>/dev/null
    kill $xephyr_pid 2>/dev/null
    rm -f /tmp/temp_target.rdp
    rm -f -- "$rdp"
    return $code
end