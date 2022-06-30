
These [WeatherFlow](https://weatherflow.com/) scripts for [Home Assistant](https://www.home-assistant.io/) provide sensor and sensor_text details for [ESPhome](https://esphome.io/) in order to display WeatherFlow data. Please follow the instructions below to successfully use these items, making changes relevant to your deployment.

**Home Assistant YAML Configuration**

[sensor.yaml](https://raw.githubusercontent.com/lux4rd0/homeassistant/main/config/scripts/weatherflow/sensor.yaml)

This file gets added to your Home Assistant configuration. I split out my main `configuration.yaml` file into sub-files. Your configruation will need an include directive in you want to do the same. Something like:

    default_config:
    sensor: !include sensor.yaml

This configruation sets up mulitple command_line collectors that poll the other scripts and takes the JSON response and creates templated values in Home Assistant. ESPhome then uses these values to display the data on the E Ink displays. A snippet looks something like this (for Current Conditions):

    - platform: command_line
      name: weatherflow_current_conditions
      json_attributes:
        - conditions
        - icon
        - relative_humidity
        - air_temperature
      command: bash /config/scripts/weatherflow/weatherflow_current_conditions.sh
      value_template: '{{ value_json.conditions }}'
      scan_interval: 300

**Home Assistant File System**

These shell script files should be placed into the Home Assistant file system. They're already configured for:

    /config/scripts/weatherflow

If you wish to place them someplace else, be sure to update each of the scripts to reflect the different folder paths. You will need to change the permissions on each file to be executable by the Home Assistant user.

    chmod 755 /config/scripts/weatherflow/*.sh

**WeatherFlow Current Conditions**

[weatherflow_current_conditions.sh](https://raw.githubusercontent.com/lux4rd0/homeassistant/main/config/scripts/weatherflow/weatherflow_current_conditions.sh)

Returns these data elements for **Current Conditions**:

        - conditions
        - icon
        - relative_humidity
        - air_temperature

from the JSON file fetched by the weatherflow_fetch_forecast.sh scripts.

**WeatherFlow Fetch Forecast**

[weatherflow_fetch_forecast.sh](https://raw.githubusercontent.com/lux4rd0/homeassistant/main/config/scripts/weatherflow/weatherflow_fetch_forecast.sh)

This script polls the [WeatherFlow API](https://weatherflow.github.io/Tempest/api/) for all the information on the forecast and current conditions. The other scripts use the output of this file to populate each Home Assistant sensor. The output of the file is called `weatherflow_forecast_out.txt` and will be created in the same folder as the scripts.

Before using it, edit the file to reflect your own WeatherFlow **Station ID** and **API token**. You can also update the units to reflect your preferences.

    WEATHERFLOW_STATION_ID="<station_id>"
    WEATHERFLOW_TOKEN="<token>"
    
    WEATHERFLOW_UNITS_TEMP="f"
    WEATHERFLOW_UNITS_WIND="mph"
    WEATHERFLOW_UNITS_PRESSURE="mmhg"
    WEATHERFLOW_UNITS_PRECIP="in"
    WEATHERFLOW_UNITS_DISTANCE="mi"

**WeatherFlow Forecast Daily**

[weatherflow_forecast_daily.sh](https://raw.githubusercontent.com/lux4rd0/homeassistant/main/config/scripts/weatherflow/weatherflow_forecast_daily.sh)

Returns these elements for **Daily Forecast**:

    - day_num
    - month_num
    - conditions
    - icon
    - air_temp_high
    - air_temp_low
    - precip_probability
    - sunrise
    - sunset
    - day_name

Requires a day parameter to be passed to the script.
*For example (the 4th day, index starts at 0):*

    bash /config/scripts/weatherflow/weatherflow_forecast_daily.sh 3

**WeatherFlow Forecast Hourly**

[weatherflow_forecast_hourly.sh](https://raw.githubusercontent.com/lux4rd0/homeassistant/main/config/scripts/weatherflow/weatherflow_forecast_hourly.sh)

Returns these elements for **Hourly Forecast**:

    - air_temperature
    - am_pm
    - conditions
    - icon
    - local_hour
    - local_hour_icon
    - pixel_height
    - precip_probability
    - precip_probability_icon

Requires an hour parameter to be passed to the script.
*For example (the 8th hour, index starts at 0):*

    bash /config/scripts/weatherflow/weatherflow_forecast_hourly.sh 7
