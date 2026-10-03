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
    # 1. Clean out conflicting monitor, layout, and keyboard codes from the source file
    grep -vE "screen|width|height|geometry|smart sizing|desktopwidth|desktopheight|keyboard" $argv > /tmp/temp_target.rdp
    
    # 2. Fixed size of one screen. 98% uses the whole home/work layout, and the
    #    RemoteApp then places itself in the gap beside the laptop.
    echo "desktopwidth:i:2560" >> /tmp/temp_target.rdp
    echo "desktopheight:i:1440" >> /tmp/temp_target.rdp
    echo "smart sizing:i:1" >> /tmp/temp_target.rdp
    echo "use multimon:i:0" >> /tmp/temp_target.rdp
    echo "desktopscalefactor:i:180" >> /tmp/temp_target.rdp

    # 3. Suppress the experimental CachyOS graphics thread locks
    set -x LIBVA_DRIVER_NAME none
    set -x FREERDP_GFX_CAPS "RFX"

    # 4. -disp: do not tell the server about the second monitor, or it
    #    repositions the window off-screen after you move it.
    xfreerdp3 /tmp/temp_target.rdp /gdi:sw /network:lan /relax-order-checks /kbd:layout:0x0000040F /size:2560x1440 /scale:180 /scale-desktop:180 /smart-sizing -disp /t:"Splunk-RDP"
    
    # 5. Automatically purge the temporary workspace file on close
    rm /tmp/temp_target.rdp
    rm $argv
end