#!/bin/bash

output=$(</config/scripts/weatherflow/weatherflow_forecast_out.txt)

current_air_temperature=$(echo "${output}" | jq '.current_conditions.air_temperature')
current_conditions=$(echo "${output}" | jq  '.current_conditions.conditions | ascii_upcase')
current_icon=$(echo "${output}" | jq -r  '.current_conditions.icon')
current_relative_humidity=$(echo "${output}" | jq -r '.current_conditions.relative_humidity')

if [ "${current_icon}" == "clear-day" ]; then current_icon="/"; fi
if [ "${current_icon}" == "clear-night" ]; then current_icon="'"; fi
if [ "${current_icon}" == "cloudy" ]; then current_icon="a"; fi
if [ "${current_icon}" == "foggy" ]; then current_icon="k"; fi
if [ "${current_icon}" == "partly-cloudy-day" ]; then current_icon="R"; fi
if [ "${current_icon}" == "partly-cloudy-night" ]; then current_icon="A"; fi
if [ "${current_icon}" == "possibly-rainy-day" ]; then current_icon="E"; fi
if [ "${current_icon}" == "possibly-rainy-night" ]; then current_icon="D"; fi
if [ "${current_icon}" == "possibly-sleet-day" ]; then current_icon="\""; fi
if [ "${current_icon}" == "possibly-sleet-night" ]; then current_icon="t"; fi
if [ "${current_icon}" == "possibly-snow-day" ]; then current_icon="P"; fi
if [ "${current_icon}" == "possibly-snow-night" ]; then current_icon="O"; fi
if [ "${current_icon}" == "possibly-thunderstorm-day" ]; then current_icon="y"; fi
if [ "${current_icon}" == "possibly-thunderstorm-night" ]; then current_icon="x"; fi
if [ "${current_icon}" == "rainy" ]; then current_icon="b"; fi
if [ "${current_icon}" == "sleet" ]; then current_icon="%%"; fi
if [ "${current_icon}" == "snow" ]; then current_icon="."; fi
if [ "${current_icon}" == "thunderstorm" ]; then current_icon="w"; fi
if [ "${current_icon}" == "windy" ]; then current_icon="j"; fi

echo "{
  \"conditions\": ${current_conditions},
  \"icon\": \"${current_icon}\",
  \"relative_humidity\": ${current_relative_humidity},
  \"air_temperature\": ${current_air_temperature}
}"