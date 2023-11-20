import json
import datetime
import sys
import os

def read_json_file(file_path):
    if not os.path.exists(file_path):
        sys.exit(f"Error: File '{file_path}' not found.")
    
    with open(file_path, 'r') as file:
        return json.load(file)

def format_time(epoch, format_string="%-I:%M"):
    return datetime.datetime.fromtimestamp(epoch).strftime(format_string).upper()

def convert_icon(icon):
    icon_map = {
        "clear-day": "/",
        "clear-night": "'",
        "cloudy": "a",
        "foggy": "k",
        "partly-cloudy-day": "R",
        "partly-cloudy-night": "A",
        "possibly-rainy-day": "E",
        "possibly-rainy-night": "D",
        "possibly-sleet-day": "\"",
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
    return icon_map.get(icon, icon)

def process_weather_data(data, day_index):
    daily_forecast = data['forecast']['daily'][day_index]
    daily_forecast['icon'] = convert_icon(daily_forecast.get('icon', ''))
    daily_forecast['day_name'] = datetime.datetime.fromtimestamp(daily_forecast['day_start_local']).strftime("%A").upper()
    daily_forecast['sunrise'] = format_time(daily_forecast['sunrise'])
    daily_forecast['sunset'] = format_time(daily_forecast['sunset'])

    # Add any other processing you need here...

    return daily_forecast

def main():
    if len(sys.argv) != 2:
        sys.exit("Usage: python script.py [day_index]")

    try:
        day_index = int(sys.argv[1])
    except ValueError:
        sys.exit("Error: Day index must be an integer.")

    file_path = '/config/scripts/weatherflow/weatherflow_forecast_out.txt'
    data = read_json_file(file_path)

    try:
        output = process_weather_data(data, day_index)
    except IndexError:
        sys.exit(f"Error: Day index {day_index} is out of range.")

    print(json.dumps(output, indent=2))

if __name__ == "__main__":
    main()

