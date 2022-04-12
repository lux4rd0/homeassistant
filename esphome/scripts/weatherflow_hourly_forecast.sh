#!/bin/bash

output=$(curl -s -X GET --header 'Accept: application/json' 'https://swd.weatherflow.com/swd/rest/better_forecast?station_id=STATION_ID&units_temp=f&units_wind=mph&units_pressure=mmhg&units_precip=in&units_distance=mi&token=TOKEN')

hour=$1

hourly_temperature_hi=$(echo "${output}" | jq .forecast.hourly[0:23] |jq ' [ .[].air_temperature ] | max ')
hourly_temperature_low=$(echo "${output}" | jq .forecast.hourly[0:23] |jq ' [ .[].air_temperature ] | min ')
hourly_temperature_difference=$(bc <<< "${hourly_temperature_hi}-${hourly_temperature_low}")

hourly_hour=$(echo "${output}" | jq -r  '.forecast.hourly['"${hour}"'].time | strflocaltime("%-I")')
hourly_am_pm=$(echo "${output}" | jq '.forecast.hourly['"${hour}"'].time | strflocaltime("%p")')

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


echo "{
  \"conditions\": ${hourly_conditions},
  \"icon\": \"${hourly_icon}\",
  \"air_temperature\": ${hourly_air_temperature},
  \"precip_probability\": ${hourly_precip_probability},
  \"local_hour\": ${hourly_hour},
  \"am_pm\": ${hourly_am_pm},
  \"pixel_height\": ${hourly_temperature_pixel_height}
}"

