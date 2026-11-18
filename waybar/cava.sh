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

cava -p "$config_file" | while read -r line; do
    echo "$line" | sed -e 's/ //g' -e 's/0/ /g' -e 's/1/▂/g' -e 's/2/▃/g' -e 's/3/▄/g' -e 's/4/▅/g' -e 's/5/▆/g' -e 's/6/▇/g' -e 's/7/█/g'
done
