#!/bin/bash

config_file=$(mktemp "${XDG_RUNTIME_DIR:-/tmp}/waybar-cava.XXXXXX") || exit 1
cat > "$config_file" <<EOF
[general]
framerate = 60
bars = 10
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
bar_delimiter = 32
EOF

cleanup() {
    rm -f "$config_file"
}
trap cleanup EXIT
trap 'exit 0' INT TERM

silence_limit=3000
printf '{"text": "", "class": "silent"}\n'

while true; do
    hidden=1
    silence_start=0

    ( cava -p "$config_file" 2>/dev/null | while IFS= read -r line; do
        now=${EPOCHREALTIME//[.,]/}
        now=$((10#$now / 1000))

        bars=${line// /}
        bars=${bars//0/▁}
        bars=${bars//1/▂}
        bars=${bars//2/▃}
        bars=${bars//3/▄}
        bars=${bars//4/▅}
        bars=${bars//5/▆}
        bars=${bars//6/▇}
        bars=${bars//7/█}

        case "$line" in
            *[1-7]*)
                hidden=0
                silence_start=0
                printf '{"text": "%s", "class": "playing"}\n' "$bars"
                ;;
            *)
                if [ "$hidden" -eq 0 ]; then
                    [ "$silence_start" -eq 0 ] && silence_start=$now
                    if [ $((now - silence_start)) -ge "$silence_limit" ]; then
                        hidden=1
                        printf '{"text": "", "class": "silent"}\n'
                    else
                        printf '{"text": "%s", "class": "playing"}\n' "$bars"
                    fi
                fi
                ;;
        esac
    done ) 2>/dev/null

    printf '{"text": "", "class": "silent"}\n'
    sleep 1
done
