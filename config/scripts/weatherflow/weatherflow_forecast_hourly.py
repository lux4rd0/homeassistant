import json
import datetime
import sys
import os


def read_json_file(file_path):
    if not os.path.exists(file_path):
        sys.exit(f"Error: File '{file_path}' not found.")

    with open(file_path, "r") as file:
        return json.load(file)


def format_time(epoch, format_string="%-I"):
    return datetime.datetime.fromtimestamp(epoch).strftime(format_string)


def format_am_pm(epoch):
    return datetime.datetime.fromtimestamp(epoch).strftime("%p")


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
        "possibly-sleet-day": '"',
        "possibly-sleet-night": "t",
        "possibly-snow-day": "P",
        "possibly-snow-night": "O",
        "possibly-thunderstorm-day": "y",
        "possibly-thunderstorm-night": "x",
        "rainy": "b",
        "sleet": "%",
        "snow": ".",
        "thunderstorm": "w",
        "windy": "j",
    }
    return icon_map.get(icon, icon)


def convert_precip_probability_icon(probability):
    precip_prob_icon_map = {
        0: "a",
        5: "b",
        10: "c",
        15: "d",
        20: "e",
        25: "f",
        30: "g",
        35: "h",
        40: "i",
        45: "j",
        50: "k",
        55: "l",
        60: "m",
        65: "n",
        70: "o",
        75: "p",
        80: "q",
        85: "r",
        90: "s",
        95: "t",
        100: "u",
    }
    return precip_prob_icon_map.get(probability, "default_icon")


def convert_hour_icon(hour, am_pm):
    hour_icon_map = {
        ("1", "AM"): "󱑋",
        ("1", "PM"): "󱐿",
        ("2", "AM"): "󱑌",
        ("2", "PM"): "󱑀",
        ("3", "AM"): "󱑍",
        ("3", "PM"): "󱑁",
        ("4", "AM"): "󱑎",
        ("4", "PM"): "󱑂",
        ("5", "AM"): "󱑏",
        ("5", "PM"): "󱑃",
        ("6", "AM"): "󱑐",
        ("6", "PM"): "󱑄",
        ("7", "AM"): "󱑑",
        ("7", "PM"): "󱑅",
        ("8", "AM"): "󱑒",
        ("8", "PM"): "󱑆",
        ("9", "AM"): "󱑓",
        ("9", "PM"): "󱑇",
        ("10", "AM"): "󱑔",
        ("10", "PM"): "󱑈",
        ("11", "AM"): "󱑕",
        ("11", "PM"): "󱑉",
        ("12", "AM"): "󱑖",
        ("12", "PM"): "󱑊",
    }
    return hour_icon_map.get((hour, am_pm), "default_icon")


def process_hourly_data(data, hour):
    hourly_forecast = data["forecast"]["hourly"]
    temp_values = [h["air_temperature"] for h in hourly_forecast[:24]]
    temp_high = max(temp_values)
    temp_low = min(temp_values)
    temp_difference = temp_high - temp_low

    hourly_data = hourly_forecast[hour]
    hourly_temp = hourly_data["air_temperature"]
    temp_pixel_height = int(
        ((hourly_temp - temp_low) / temp_difference) * 100
    )  # Convert to integer

    hourly_icon = convert_icon(hourly_data["icon"])
    hourly_precip_probability_icon = convert_precip_probability_icon(
        hourly_data["precip_probability"]
    )
    hourly_hour = format_time(hourly_data["time"])
    hourly_am_pm = format_am_pm(hourly_data["time"])
    hourly_hour_icon = convert_hour_icon(hourly_hour, hourly_am_pm)

    return {
        "conditions": hourly_data["conditions"],
        "icon": hourly_icon,
        "air_temperature": hourly_temp,
        "precip_probability": hourly_data["precip_probability"],
        "precip_probability_icon": hourly_precip_probability_icon,
        "local_hour": hourly_hour,
        "local_hour_icon": hourly_hour_icon,
        "am_pm": hourly_am_pm,
        "pixel_height": temp_pixel_height,
    }


def main():
    if len(sys.argv) != 2:
        sys.exit("Usage: python script.py [hour_index]")

    try:
        hour_index = int(sys.argv[1])
    except ValueError:
        sys.exit("Error: Hour index must be an integer.")

    file_path = "/config/scripts/weatherflow/weatherflow_forecast_out.txt"
    data = read_json_file(file_path)

    try:
        output = process_hourly_data(data, hour_index)
    except IndexError:
        sys.exit(f"Error: Hour index {hour_index} is out of range.")

    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()

