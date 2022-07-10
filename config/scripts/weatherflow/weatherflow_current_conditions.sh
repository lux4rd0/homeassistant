#!/bin/bash

output=$(</config/scripts/weatherflow/weatherflow_forecast_out.txt)

eval "$(echo "${output}" | jq -r '.current_conditions | to_entries | .[] | .key + "=" + (.value | @sh)')"

if [ "${icon}" == "clear-day" ]; then icon="/"; fi
if [ "${icon}" == "clear-night" ]; then icon="'"; fi
if [ "${icon}" == "cloudy" ]; then icon="a"; fi
if [ "${icon}" == "foggy" ]; then icon="k"; fi
if [ "${icon}" == "partly-cloudy-day" ]; then icon="R"; fi
if [ "${icon}" == "partly-cloudy-night" ]; then icon="A"; fi
if [ "${icon}" == "possibly-rainy-day" ]; then icon="E"; fi
if [ "${icon}" == "possibly-rainy-night" ]; then icon="D"; fi
if [ "${icon}" == "possibly-sleet-day" ]; then icon="\""; fi
if [ "${icon}" == "possibly-sleet-night" ]; then icon="t"; fi
if [ "${icon}" == "possibly-snow-day" ]; then icon="P"; fi
if [ "${icon}" == "possibly-snow-night" ]; then icon="O"; fi
if [ "${icon}" == "possibly-thunderstorm-day" ]; then icon="y"; fi
if [ "${icon}" == "possibly-thunderstorm-night" ]; then icon="x"; fi
if [ "${icon}" == "rainy" ]; then icon="b"; fi
if [ "${icon}" == "sleet" ]; then icon="%%"; fi
if [ "${icon}" == "snow" ]; then icon="."; fi
if [ "${icon}" == "thunderstorm" ]; then icon="w"; fi
if [ "${icon}" == "windy" ]; then icon="j"; fi

time=$(echo "${output}" | jq -r '.current_conditions.time | strflocaltime("%b %-d, %Y %-I:%M %p") | ascii_upcase')
lightning_strike_last_epoch=$(echo "${output}" | jq -r '.current_conditions.lightning_strike_last_epoch | strflocaltime("%b %-d, %Y %-I:%M %p") | ascii_upcase')
conditions=$(echo "${output}" | jq -r '.current_conditions.conditions | ascii_upcase')
pressure_trend=$(echo "${output}" | jq -r '.current_conditions.pressure_trend | ascii_upcase')
lightning_strike_last_distance_msg=$(echo "${output}" | jq -r '.current_conditions.lightning_strike_last_distance_msg | ascii_upcase')

echo "{
  \"time\": \"${time}\",
  \"conditions\": \"${conditions}\",
  \"icon\": \"${icon}\",
  \"air_temperature\": ${air_temperature},
  \"sea_level_pressure\": ${sea_level_pressure},
  \"station_pressure\": ${station_pressure},
  \"pressure_trend\": \"${pressure_trend}\",
  \"relative_humidity\": ${relative_humidity},
  \"wind_avg\": ${wind_avg},
  \"wind_direction\": ${wind_direction},
  \"wind_direction_cardinal\": \"${wind_direction_cardinal}\",
  \"wind_gust\": ${wind_gust},
  \"solar_radiation\": ${solar_radiation},
  \"uv\": ${uv},
  \"brightness\": ${brightness},
  \"feels_like\": ${feels_like},
  \"dew_point\": ${dew_point},
  \"wet_bulb_temperature\": ${wet_bulb_temperature},
  \"wet_bulb_globe_temperature\": ${wet_bulb_globe_temperature},
  \"delta_t\": ${delta_t},
  \"air_density\": ${air_density},
  \"lightning_strike_count_last_1hr\": ${lightning_strike_count_last_1hr},
  \"lightning_strike_count_last_3hr\": ${lightning_strike_count_last_3hr},
  \"lightning_strike_last_distance\": ${lightning_strike_last_distance},
  \"lightning_strike_last_distance_msg\": \"${lightning_strike_last_distance_msg}\",
  \"lightning_strike_last_epoch\": \"${lightning_strike_last_epoch}\",
  \"precip_accum_local_day\": ${precip_accum_local_day},
  \"precip_accum_local_yesterday\": ${precip_accum_local_yesterday},
  \"precip_minutes_local_day\": ${precip_minutes_local_day},
  \"precip_minutes_local_yesterday\": ${precip_minutes_local_yesterday},
  \"is_precip_local_day_rain_check\": \"${is_precip_local_day_rain_check}\",
  \"is_precip_local_yesterday_rain_check\": \"${is_precip_local_yesterday_rain_check}\"
}"
