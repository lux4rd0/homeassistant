#!/bin/bash

output=$(</config/scripts/weatherflow/weatherflow_forecast_out.txt)

daily_day_name=$(echo "${output}" | jq -r '.forecast.daily['"$1"'].day_start_local | strflocaltime("%A") | ascii_upcase')

daily_day_num=$(echo "${output}" | jq -r '.forecast.daily['"$1"'].day_num')
daily_month_num=$(echo "${output}" | jq -r '.forecast.daily['"$1"'].month_num')

daily_air_temp_high=$(echo "${output}" | jq -r '.forecast.daily['"$1"'].air_temp_high')
daily_air_temp_low=$(echo "${output}" | jq -r '.forecast.daily['"$1"'].air_temp_low')

daily_conditions=$(echo "${output}" | jq -r '.forecast.daily['"$1"'].conditions | ascii_upcase')

daily_icon=$(echo "${output}" | jq -r  '.forecast.daily['"$1"'].icon')
daily_precip_probability=$(echo "${output}" | jq -r '.forecast.daily['"$1"'].precip_probability')

daily_sunrise=$(echo "${output}" | jq -r '.forecast.daily['"$1"'].sunrise | strflocaltime("%-I:%M")')
daily_sunset=$(echo "${output}" | jq -r '.forecast.daily['"$1"'].sunset | strflocaltime("%-I:%M")')

if [ "${daily_icon}" == "clear-day" ]; then daily_icon="/"; fi
if [ "${daily_icon}" == "clear-night" ]; then daily_icon="'"; fi
if [ "${daily_icon}" == "cloudy" ]; then daily_icon="a"; fi
if [ "${daily_icon}" == "foggy" ]; then daily_icon="k"; fi
if [ "${daily_icon}" == "partly-cloudy-day" ]; then daily_icon="R"; fi
if [ "${daily_icon}" == "partly-cloudy-night" ]; then daily_icon="A"; fi
if [ "${daily_icon}" == "possibly-rainy-day" ]; then daily_icon="E"; fi
if [ "${daily_icon}" == "possibly-rainy-night" ]; then daily_icon="D"; fi
if [ "${daily_icon}" == "possibly-sleet-day" ]; then daily_icon='\"'; fi
if [ "${daily_icon}" == "possibly-sleet-night" ]; then daily_icon="t"; fi
if [ "${daily_icon}" == "possibly-snow-day" ]; then daily_icon="P"; fi
if [ "${daily_icon}" == "possibly-snow-night" ]; then daily_icon="O"; fi
if [ "${daily_icon}" == "possibly-thunderstorm-day" ]; then daily_icon="y"; fi
if [ "${daily_icon}" == "possibly-thunderstorm-night" ]; then daily_icon="x"; fi
if [ "${daily_icon}" == "rainy" ]; then daily_icon="b"; fi
if [ "${daily_icon}" == "sleet" ]; then daily_icon="%%"; fi
if [ "${daily_icon}" == "snow" ]; then daily_icon="."; fi
if [ "${daily_icon}" == "thunderstorm" ]; then daily_icon="w"; fi
if [ "${daily_icon}" == "windy" ]; then daily_icon="j"; fi

echo "{
  \"conditions\": \"${daily_conditions}\",
  \"icon\": \"${daily_icon}\",
  \"day_name\": \"${daily_day_name}\",
  \"air_temp_high\": ${daily_air_temp_high},
  \"air_temp_low\": ${daily_air_temp_low},
  \"precip_probability\": ${daily_precip_probability},
  \"day_num\": ${daily_day_num},
  \"month_num\": ${daily_month_num},
  \"sunrise\": \"${daily_sunrise}\",
  \"sunset\": \"${daily_sunset}\"
}"