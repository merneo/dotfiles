#!/bin/bash

# Fetch weather data from wttr.in for Prague
weather_data=$(curl -s "https://wttr.in/Prague?format=j1")

if [ -z "$weather_data" ]; then
    echo '{"text": "No data", "class": "error"}'
    exit 1
fi

# Extract temperature and weather description
temp=$(echo "$weather_data" | jq -r '.current_condition[0].temp_C')
desc=$(echo "$weather_data" | jq -r '.current_condition[0].weatherDesc[0].value')
humidity=$(echo "$weather_data" | jq -r '.current_condition[0].humidity')

if [ -z "$temp" ] || [ "$temp" = "null" ]; then
    echo '{"text": "No data", "class": "error"}'
    exit 1
fi

# Weather icon mapping based on weather code
weather_code=$(echo "$weather_data" | jq -r '.current_condition[0].weatherCode')

case "$weather_code" in
    # Sunny
    113) icon="☀️" ;;
    # Partly cloudy
    116|119|122) icon="⛅" ;;
    # Cloudy/Overcast
    143|144|150) icon="☁️" ;;
    # Mist/Fog
    248|260) icon="🌫️" ;;
    # Drizzle
    176|179|182|185) icon="🌧️" ;;
    # Rain
    200|227|230|233|263|266|269|272|275|278|281|284|293|296|299) icon="🌧️" ;;
    # Snow
    179|182|185|227|230|233|308|311|314|317|320|323|326|329|332|335|338|350|353|356|359|362|365|368|371|374|377|386|389|392|395) icon="❄️" ;;
    # Thunderstorm
    200|386|389|392|395) icon="⛈️" ;;
    *) icon="🌤️" ;;
esac

# Output JSON for waybar
echo "{\"text\": \"$icon ${temp}°C\", \"class\": \"weather\", \"tooltip\": \"$desc (Humidity: ${humidity}%)\"}"
