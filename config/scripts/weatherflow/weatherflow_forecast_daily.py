import json
import datetime
import sys

def safe_parse_date(date_str):
    try:
        return datetime.datetime.fromtimestamp(date_str).strftime("%A").upper()
    except (TypeError, ValueError):
        return "Unknown"

def safe_parse_time(time_str):
    try:
        return datetime.datetime.fromtimestamp(time_str).strftime("%-I:%M")
    except (TypeError, ValueError):
        return "Unknown"

# Reading index from command line
if len(sys.argv) < 2:
    print("Usage: script.py <index>")
    sys.exit(1)

try:
    index = int(sys.argv[1])
except ValueError:
    print("Index must be an integer.")
    sys.exit(1)

# Check if index is within the valid range (0-9)
if index < 0 or index > 9:
    print("Index must be between 0 and 9.")
    sys.exit(1)

# Loading JSON data
try:
    with open("/config/scripts/weatherflow/weatherflow_forecast_out.txt", "r") as file:
        data = json.load(file)
except json.JSONDecodeError:
    print("Error parsing JSON file.")
    sys.exit(1)

# Extracting data for the specified day
daily_data = data['forecast']['daily'][index]
daily_day_name = safe_parse_date(daily_data.get('day_start_local'))
daily_day_num = daily_data.get('day_num', "Unknown")
daily_month_num = daily_data.get('month_num', "Unknown")
daily_air_temp_high = daily_data.get('air_temp_high', "Unknown")
daily_air_temp_low = daily_data.get('air_temp_low', "Unknown")

# Calculating temperature range for percentage calculations
forecast_temperatures = [day['air_temp_high'] for day in data['forecast']['daily'][0:9]] + \
                         [day['air_temp_low'] for day in data['forecast']['daily'][0:9]]
forecast_temperature_high = max(forecast_temperatures)
forecast_temperature_low = min(forecast_temperatures)
forecast_temperature_difference = forecast_temperature_high - forecast_temperature_low

# Calculating percentages as integers
air_temp_low_x = int(((daily_air_temp_low - forecast_temperature_low) / forecast_temperature_difference) * 100)
air_temp_high_x = int(100 - ((forecast_temperature_high - daily_air_temp_high) / forecast_temperature_difference) * 100)

# Other details
daily_conditions = daily_data.get('conditions', "Unknown").upper()
daily_icon = daily_data.get('icon', "Unknown")
daily_precip_probability = daily_data.get('precip_probability', "Unknown")
daily_sunrise = safe_parse_time(daily_data.get('sunrise'))
daily_sunset = safe_parse_time(daily_data.get('sunset'))

# Icon mapping
icon_mapping = {
    "clear-day": "/",
    "clear-night": "'",
    "cloudy": "a",
    "foggy": "k",
    "partly-cloudy-day": "R",
    "partly-cloudy-night": "A",
    "possibly-rainy-day": "E",
    "possibly-rainy-night": "D",
    "possibly-sleet-day": '\"',
    "possibly-sleet-night": "t",
    "possibly-snow-day": "P",
    "possibly-snow-night": "O",
    "possibly-thunderstorm-day": "y",
    "possibly-thunderstorm-night": "x",
    "rainy": "b",
    "sleet": "%",
    "snow": ".",
    "thunderstorm": "w",
    "windy": "j"
}

daily_icon = icon_mapping.get(daily_icon, daily_icon)  # Default to original icon if not found in mapping

# Output
output = {
    "conditions": daily_conditions,
    "icon": daily_icon,
    "day_name": daily_day_name,
    "air_temp_high": daily_air_temp_high,
    "air_temp_high_x": air_temp_high_x,
    "air_temp_low": daily_air_temp_low,
    "air_temp_low_x": air_temp_low_x,
    "precip_probability": daily_precip_probability,
    "day_num": daily_day_num,
    "month_num": daily_month_num,
    "sunrise": daily_sunrise,
    "sunset": daily_sunset
}

print(json.dumps(output, indent=2))
