#!/bin/bash

WEATHERFLOW_STATION_ID="<station_id>"
WEATEHRFLOW_TOKEN="<token>"

WEATEHRFLOW_UNITS_TEMP="f"
WEATEHRFLOW_UNITS_WIND="mph"
WEATEHRFLOW_UNITS_PRESSURE="mmhg"
WEATEHRFLOW_UNITS_PRECIP="in"
WEATEHRFLOW_UNITS_DISTANCE="mi"

URL="https://swd.weatherflow.com/swd/rest/better_forecast?station_id=${WEATHERFLOW_STATION_ID}&units_temp=${WEATEHRFLOW_UNITS_TEMP}&units_wind=${WEATEHRFLOW_UNITS_WIND}&units_pressure=${WEATEHRFLOW_UNITS_PRESSURE}&units_precip=${WEATEHRFLOW_UNITS_PRECIP}&units_distance=${WEATEHRFLOW_UNITS_DISTANCE}&token=${WEATEHRFLOW_TOKEN}"

curl -s -X GET --header 'Accept: application/json' "${URL}" -o /config/scripts/weatherflow/weatherflow_forecast_out.txt.tmp
mv /config/scripts/weatherflow/weatherflow_forecast_out.txt.tmp /config/scripts/weatherflow/weatherflow_forecast_out.txt