#!/bin/bash

# =============================================================================
# WAYBAR WEATHER SCRIPT
# Author: merneo
# Purpose: Fetches weather data from wttr.in and formats it as JSON for Waybar.
# Dependencies: curl, jq
# =============================================================================

# 1. Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo '{"text": "Err: jq", "tooltip": "jq is missing. Please install it."}'
    exit 0
fi

# 2. Fetch weather data
# -s: Silent mode
# --max-time 5: Timeout after 5 seconds to prevent Waybar hanging
# format=j1: Request JSON output
# URL ends with /?format=j1 to auto-detect location based on IP
weather_data=$(curl --max-time 5 -s "https://wttr.in/?format=j1")

# 3. Handle connection errors
if [ $? -ne 0 ] || [ -z "$weather_data" ]; then
    echo '{"text": "Offline", "tooltip": "Cannot reach wttr.in. Check internet connection."}'
    exit 0
fi

# 4. Parse JSON Data
temp=$(echo "$weather_data" | jq -r '.current_condition[0].temp_C' 2>/dev/null)
desc=$(echo "$weather_data" | jq -r '.current_condition[0].weatherDesc[0].value' 2>/dev/null)
humidity=$(echo "$weather_data" | jq -r '.current_condition[0].humidity' 2>/dev/null)
# Try to get city name, fallback to "Unknown" if missing
city=$(echo "$weather_data" | jq -r '.nearest_area[0].areaName[0].value // "Unknown Loc"' 2>/dev/null)
weather_code=$(echo "$weather_data" | jq -r '.current_condition[0].weatherCode' 2>/dev/null)

# 5. Validate Data
if [ -z "$temp" ] || [ "$temp" = "null" ]; then
    echo '{"text": "API Error", "tooltip": "Received invalid JSON from wttr.in"}'
    exit 0
fi

# 6. Map Icons based on WMO Weather Codes
case "$weather_code" in
    113) icon="☀️" ;;
    116|119|122) icon="⛅" ;;
    143|144|150) icon="☁️" ;;
    248|260) icon="🌫️" ;;
    176|179|182|185) icon="🌧️" ;;
    200|227|230|233|263|266|269|272|275|278|281|284|293|296|299) icon="🌧️" ;;
    308|311|314|317|320|323|326|329|332|335|338) icon="❄️" ;;
    179|182|185|227|230|233|350|353|356|359|362|365|368|371|374|377|386|389|392|395) icon="🌨️" ;;
    200|386|389|392|395) icon="⛈️" ;;
    *) icon="🌤️" ;;
esac

# 7. Output JSON
# Text: Icon + Temp
# Tooltip: City, Description, Humidity
echo "{"text": "$icon ${temp}°C", "tooltip": "$city\n$desc\nHumidity: ${humidity}%"}"