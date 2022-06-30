#!/bin/bash

WEATHERFLOW_STATION_ID="<station_id>"
WEATHERFLOW_TOKEN="<token>"

WEATHERFLOW_UNITS_TEMP="f"
WEATHERFLOW_UNITS_WIND="mph"
WEATHERFLOW_UNITS_PRESSURE="mmhg"
WEATHERFLOW_UNITS_PRECIP="in"
WEATHERFLOW_UNITS_DISTANCE="mi"

URL="https://swd.weatherflow.com/swd/rest/better_forecast?station_id=${WEATHERFLOW_STATION_ID}&units_temp=${WEATHERFLOW_UNITS_TEMP}&units_wind=${WEATHERFLOW_UNITS_WIND}&units_pressure=${WEATHERFLOW_UNITS_PRESSURE}&units_precip=${WEATHERFLOW_UNITS_PRECIP}&units_distance=${WEATHERFLOW_UNITS_DISTANCE}&token=${WEATHERFLOW_TOKEN}"

curl -s -X GET --header 'Accept: application/json' "${URL}" -o /config/scripts/weatherflow/weatherflow_forecast_out.txt.tmp
mv /config/scripts/weatherflow/weatherflow_forecast_out.txt.tmp /config/scripts/weatherflow/weatherflow_forecast_out.txt
