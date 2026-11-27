#!/bin/bash

temp=""
for d in /sys/class/hwmon/hwmon*; do
    [ -r "$d/name" ] || continue
    case "$(cat "$d/name" 2>/dev/null)" in
        k10temp|coretemp|cpu_thermal|zenpower)
            raw=$(cat "$d/temp1_input" 2>/dev/null)
            if [ -n "$raw" ]; then
                temp=$((raw / 1000))
                break
            fi
            ;;
    esac
done

if [ -z "$temp" ]; then
    printf '{"text": "", "class": "silent"}\n'
    exit 0
fi

class="normal"
[ "$temp" -ge 72 ] && class="warm"
[ "$temp" -ge 85 ] && class="hot"

printf '{"text": "%s°C", "class": "%s", "tooltip": "CPU %s°C"}\n' "$temp" "$class" "$temp"
