import requests

# Set the WeatherFlow parameters
WEATHERFLOW_STATION_ID = "120666"
WEATHERFLOW_TOKEN = "a22afea7-00cc-4918-909a-923dd339f41c"

WEATHERFLOW_UNITS_TEMP = "f"
WEATHERFLOW_UNITS_WIND = "mph"
WEATHERFLOW_UNITS_PRESSURE = "inhg"
WEATHERFLOW_UNITS_PRECIP = "in"
WEATHERFLOW_UNITS_DISTANCE = "mi"

# Construct the URL
URL = f"https://swd.weatherflow.com/swd/rest/better_forecast?station_id={WEATHERFLOW_STATION_ID}&units_temp={WEATHERFLOW_UNITS_TEMP}&units_wind={WEATHERFLOW_UNITS_WIND}&units_pressure={WEATHERFLOW_UNITS_PRESSURE}&units_precip={WEATHERFLOW_UNITS_PRECIP}&units_distance={WEATHERFLOW_UNITS_DISTANCE}&token={WEATHERFLOW_TOKEN}"

# Make the GET request
response = requests.get(URL)

# Check if the request was successful
if response.status_code == 200:
    # Define the file path
    file_path = "/config/scripts/weatherflow/weatherflow_forecast_out.txt"

    # Write response to the file
    with open(file_path, "w") as file:
        file.write(response.text)
else:
    print(f"Failed to retrieve data: {response.status_code}")

