import json
import datetime

def read_json_file(file_path):
    with open(file_path, 'r') as file:
        return json.load(file)

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

def format_time(epoch):
    return datetime.datetime.fromtimestamp(epoch).strftime("%b %-d, %Y %-I:%M %p").upper()

# Read the JSON data
data = read_json_file('/config/scripts/weatherflow/weatherflow_forecast_out.txt')

# Extract current conditions
current_conditions = data['current_conditions']

# Convert icon
current_conditions['icon'] = convert_icon(current_conditions.get('icon', ''))

# Format additional data
current_conditions['time'] = format_time(current_conditions.get('time', 0))
current_conditions['lightning_strike_last_epoch'] = format_time(current_conditions.get('lightning_strike_last_epoch', 0))
current_conditions['conditions'] = current_conditions.get('conditions', '').upper()
current_conditions['pressure_trend'] = current_conditions.get('pressure_trend', '').upper()
current_conditions['lightning_strike_last_distance_msg'] = current_conditions.get('lightning_strike_last_distance_msg', '').upper()

# Output formatted data as JSON
print(json.dumps(current_conditions, indent=2))

