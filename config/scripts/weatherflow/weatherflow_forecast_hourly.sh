#!/bin/bash

output=$(</config/scripts/weatherflow/weatherflow_forecast_out.txt)

hour=$1

hourly_temperature_hi=$(echo "${output}" | jq .forecast.hourly[0:23] |jq ' [ .[].air_temperature ] | max ')
hourly_temperature_low=$(echo "${output}" | jq .forecast.hourly[0:23] |jq ' [ .[].air_temperature ] | min ')
hourly_temperature_difference=$(bc <<< "${hourly_temperature_hi}-${hourly_temperature_low}")

hourly_hour=$(echo "${output}" | jq -r  '.forecast.hourly['"${hour}"'].time | strflocaltime("%-I")')
hourly_am_pm=$(echo "${output}" | jq -r '.forecast.hourly['"${hour}"'].time | strflocaltime("%p")')

hourly_air_temperature=$(echo "${output}" | jq '.forecast.hourly['"${hour}"'].air_temperature')
hourly_temperature_pixel_height=$(bc <<< "scale=2;((${hourly_air_temperature}-${hourly_temperature_low})/${hourly_temperature_difference})*100")

hourly_conditions=$(echo "${output}" | jq  '.forecast.hourly['"${hour}"'].conditions')

hourly_icon=$(echo "${output}" | jq -r  '.forecast.hourly['"${hour}"'].icon')
hourly_precip_probability=$(echo "${output}" | jq  '.forecast.hourly['"${hour}"'].precip_probability')


if [ "${hourly_icon}" == "clear-day" ]; then hourly_icon="/"; fi
if [ "${hourly_icon}" == "clear-night" ]; then hourly_icon="'"; fi
if [ "${hourly_icon}" == "cloudy" ]; then hourly_icon="a"; fi
if [ "${hourly_icon}" == "foggy" ]; then hourly_icon="k"; fi
if [ "${hourly_icon}" == "partly-cloudy-day" ]; then hourly_icon="R"; fi
if [ "${hourly_icon}" == "partly-cloudy-night" ]; then hourly_icon="A"; fi
if [ "${hourly_icon}" == "possibly-rainy-day" ]; then hourly_icon="E"; fi
if [ "${hourly_icon}" == "possibly-rainy-night" ]; then hourly_icon="D"; fi
if [ "${hourly_icon}" == "possibly-sleet-day" ]; then hourly_icon="\""; fi
if [ "${hourly_icon}" == "possibly-sleet-night" ]; then hourly_icon="t"; fi
if [ "${hourly_icon}" == "possibly-snow-day" ]; then hourly_icon="P"; fi
if [ "${hourly_icon}" == "possibly-snow-night" ]; then hourly_icon="O"; fi
if [ "${hourly_icon}" == "possibly-thunderstorm-day" ]; then hourly_icon="y"; fi
if [ "${hourly_icon}" == "possibly-thunderstorm-night" ]; then hourly_icon="x"; fi
if [ "${hourly_icon}" == "rainy" ]; then hourly_icon="b"; fi
if [ "${hourly_icon}" == "sleet" ]; then hourly_icon="%%"; fi
if [ "${hourly_icon}" == "snow" ]; then hourly_icon="."; fi
if [ "${hourly_icon}" == "thunderstorm" ]; then hourly_icon="w"; fi
if [ "${hourly_icon}" == "windy" ]; then hourly_icon="j"; fi

if [ "${hourly_precip_probability}" == "0" ]; then hourly_precip_probability_icon="a"; fi
if [ "${hourly_precip_probability}" == "5" ]; then hourly_precip_probability_icon="b"; fi
if [ "${hourly_precip_probability}" == "10" ]; then hourly_precip_probability_icon="c"; fi
if [ "${hourly_precip_probability}" == "15" ]; then hourly_precip_probability_icon="d"; fi
if [ "${hourly_precip_probability}" == "20" ]; then hourly_precip_probability_icon="e"; fi
if [ "${hourly_precip_probability}" == "25" ]; then hourly_precip_probability_icon="f"; fi
if [ "${hourly_precip_probability}" == "30" ]; then hourly_precip_probability_icon="g"; fi
if [ "${hourly_precip_probability}" == "35" ]; then hourly_precip_probability_icon="h"; fi
if [ "${hourly_precip_probability}" == "40" ]; then hourly_precip_probability_icon="i"; fi
if [ "${hourly_precip_probability}" == "45" ]; then hourly_precip_probability_icon="j"; fi
if [ "${hourly_precip_probability}" == "50" ]; then hourly_precip_probability_icon="k"; fi
if [ "${hourly_precip_probability}" == "55" ]; then hourly_precip_probability_icon="l"; fi
if [ "${hourly_precip_probability}" == "60" ]; then hourly_precip_probability_icon="m"; fi
if [ "${hourly_precip_probability}" == "65" ]; then hourly_precip_probability_icon="n"; fi
if [ "${hourly_precip_probability}" == "70" ]; then hourly_precip_probability_icon="o"; fi
if [ "${hourly_precip_probability}" == "75" ]; then hourly_precip_probability_icon="p"; fi
if [ "${hourly_precip_probability}" == "80" ]; then hourly_precip_probability_icon="q"; fi
if [ "${hourly_precip_probability}" == "85" ]; then hourly_precip_probability_icon="r"; fi
if [ "${hourly_precip_probability}" == "90" ]; then hourly_precip_probability_icon="s"; fi
if [ "${hourly_precip_probability}" == "95" ]; then hourly_precip_probability_icon="t"; fi
if [ "${hourly_precip_probability}" == "100" ]; then hourly_precip_probability_icon="u"; fi


if [ "${hourly_hour}" == "1" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑋"; fi
if [ "${hourly_hour}" == "1" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱐿"; fi

if [ "${hourly_hour}" == "2" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑌"; fi
if [ "${hourly_hour}" == "2" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑀"; fi

if [ "${hourly_hour}" == "3" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑍"; fi
if [ "${hourly_hour}" == "3" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑁"; fi

if [ "${hourly_hour}" == "4" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑎"; fi
if [ "${hourly_hour}" == "4" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑂"; fi

if [ "${hourly_hour}" == "5" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑏"; fi
if [ "${hourly_hour}" == "5" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑃"; fi

if [ "${hourly_hour}" == "6" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑐"; fi
if [ "${hourly_hour}" == "6" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑄"; fi

if [ "${hourly_hour}" == "7" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑑"; fi
if [ "${hourly_hour}" == "7" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑅"; fi

if [ "${hourly_hour}" == "8" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑒"; fi
if [ "${hourly_hour}" == "8" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑆"; fi

if [ "${hourly_hour}" == "9" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑓"; fi
if [ "${hourly_hour}" == "9" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑇"; fi

if [ "${hourly_hour}" == "10" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑔"; fi
if [ "${hourly_hour}" == "10" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑈"; fi

if [ "${hourly_hour}" == "11" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑕"; fi
if [ "${hourly_hour}" == "11" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑉"; fi

if [ "${hourly_hour}" == "12" ] && [ "${hourly_am_pm}" == "AM" ]; then hourly_hour_icon="󱑖"; fi
if [ "${hourly_hour}" == "12" ] && [ "${hourly_am_pm}" == "PM" ]; then hourly_hour_icon="󱑊"; fi


echo "{
  \"conditions\": ${hourly_conditions},
  \"icon\": \"${hourly_icon}\",
  \"air_temperature\": ${hourly_air_temperature},
  \"precip_probability\": ${hourly_precip_probability},
  \"precip_probability_icon\": \"${hourly_precip_probability_icon}\",
  \"local_hour\": ${hourly_hour},
  \"local_hour_icon\": \"${hourly_hour_icon}\",
  \"am_pm\": \"${hourly_am_pm}\",
  \"pixel_height\": ${hourly_temperature_pixel_height}
}"