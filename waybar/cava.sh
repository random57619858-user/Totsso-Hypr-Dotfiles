#!/bin/bash

config_file="/tmp/waybar_cava_config"
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
    exit 0
}
trap cleanup INT TERM

silence_limit=3000
printf '{"text": "", "class": "silent"}\n'

while true; do
    hidden=1
    silence_start=""

    ( cava -p "$config_file" 2>/dev/null | while IFS= read -r line; do
        now=${EPOCHREALTIME/./}
        now=$((now / 1000))

        case "$line" in
            *[1-7]*)
                bars=$(printf '%s' "$line" | sed -e 's/ //g' -e 's/0/ /g' \
                    -e 's/1/▂/g' -e 's/2/▃/g' -e 's/3/▄/g' -e 's/4/▅/g' \
                    -e 's/5/▆/g' -e 's/6/▇/g' -e 's/7/█/g')
                printf '{"text": "%s", "class": "playing"}\n' "$bars"
                hidden=0
                silence_start=""
                ;;
            *)
                if [ "$hidden" -eq 0 ]; then
                    [ -z "$silence_start" ] && silence_start=$now
                    if [ $((now - silence_start)) -ge "$silence_limit" ]; then
                        printf '{"text": "", "class": "silent"}\n'
                        hidden=1
                        silence_start=""
                    fi
                fi
                ;;
        esac
    done
    ) 2>/dev/null

    printf '{"text": "", "class": "silent"}\n'
    sleep 1
done
