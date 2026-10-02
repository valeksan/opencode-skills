#!/bin/bash
# Cyberpunk Conky — always on the RIGHTMOST monitor

# Wait for X display: at session start this unit may run before XWayland is up
# (conky crashed with "can't open display" -> coredump -> drkonqi noise).
if [ -z "$DISPLAY" ]; then
    for _ in $(seq 60); do
        xsock=$(ls /tmp/.X11-unix/X* 2>/dev/null | head -1)
        if [ -n "$xsock" ]; then
            export DISPLAY=":${xsock##*/X}"
            break
        fi
        sleep 0.5
    done
fi

# Kill any existing conky instance (KDE session restore may have launched one)
pkill -f 'conky -c.*cyberpunk' 2>/dev/null
sleep 1

# Find rightmost monitor index
RIGHTMOST=$(xrandr --listmonitors 2>/dev/null | awk '
    /:/ {
        idx = $1
        for (i=1; i<=NF; i++) {
            if (match($i, /\+[0-9]+\+[0-9]+/)) {
                split($i, pos, "+")
                x = pos[2]
                if (x+0 > max_x+0) { max_x = x; best = idx }
            }
        }
    }
    END { print best+0 }
')
[ -z "$RIGHTMOST" ] && RIGHTMOST=0

# Launch conky on that monitor
conky -c ~/.config/conky/cyberpunk.conf -m "$RIGHTMOST" -d

# Click-through: clear the input shape of the conky window so mouse events
# (selection, clicks) pass through it to the desktop below. Must run after
# every conky start — a new window gets a fresh (full) input shape.
if [ -x "$HOME/.local/bin/xshape-input-clear" ]; then
    CWID=""
    for _ in $(seq 30); do
        CWID=$(xdotool search --class '^Conky$' 2>/dev/null | head -1)
        [ -n "$CWID" ] && break
        CWID=$(xwininfo -root -tree 2>/dev/null | awk -F'"' '/"conky \(/{print $1; exit}' | tr -d ' ')
        [ -n "$CWID" ] && break
        sleep 0.2
    done
    if [ -n "$CWID" ]; then
        "$HOME/.local/bin/xshape-input-clear" "$CWID"
    else
        echo "conky window not found, click-through NOT applied"
    fi
fi
