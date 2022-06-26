**WeatherFlow - Lilygo T5 4.7" Screen**

[lilygo_t5_weatherflow.yaml](https://raw.githubusercontent.com/lux4rd0/homeassistant/main/esphome/lilygo_t5_weatherflow.yaml)

There are three screens built into one YAML configuration file. They represent:

**WeatherFlow 24-Hour Precipitation Forecast with 9-Room Temperature & Humidity**

![enter image description here](https://labs.lux4rd0.com/wp-content/uploads/2022/06/lilygo_t5_WeatherFlow-24-Hour-Precipitation-Forecast-with-9-Room-Temperature-Humidity-300x168.png)

**WeatherFlow 3-Day Overview with 24-Hour Precipitation Forecast**

![enter image description here](https://labs.lux4rd0.com/wp-content/uploads/2022/06/lilygo_t5_WeatherFlow-3-Day-Overview-with-24-Hour-Precipitation-Forecast-300x168.png)

**WeatherFlow 4-Day Overview**

![enter image description here](https://labs.lux4rd0.com/wp-content/uploads/2022/06/lilygo_t5_WeatherFlow-4-Day-Overview-300x168.png)

YAML file details:

    substitutions:
      devicename: weatherflow_display
      run_time: 2min
      sleep_time: 15min
      night_sleep_time: 375min

Provides for device name substituion. Any of the common sensors, buttons, switches, etc. - get swapped in for this name. I normally use the hostname. run_time and sleep_time are for the intervals providing for deep sleep. Night Sleep Time is for the 6 hours set for an overnight sleep. Normally this would be 360 minutes for 6 hours, but there's a fair amount of system clock drift during sleep - so I set this just over the 360 minutes so it doesn't get stuck when it wakes up in the morning.

    esp32:
      board: m5stack-core2
      framework:
        type: arduino
        version: 2.0.2
        platform_version: '4.3.0'

The Lilygo T5 isn't in the official [esp32 board list](https://registry.platformio.org/platforms/platformio/espressif32/boards) yet but the [m5stack-core2](https://docs.platformio.org/en/latest/boards/espressif32/m5stack-core2.html) has the same configurations. This helps with the 16MB Flash 8MB PSRAM. The reason we're specificying the framework is that using a lot of sensors from Home Assistant causes some kernal panics at startup. Once ESPhome is updated to newer frameworks, this may be removed.

    wifi:
      ssid: !secret wifi_ssid
      password: !secret wifi_password
      ap:
        ssid: '${devicename}'
        password: !secret wifi_password
      domain: .tylephony.com
      power_save_mode: none

This most likely can be what you've already templated with your ESPhome. justing using secrets files and domain names to help find my devices more consistently.

    deep_sleep:
      run_duration: '${run_time}'
      sleep_duration: '${sleep_time}'
      id: deep_sleep_control
      esp32_ext1_wakeup:
        pins: GPIO39
        mode: ALL_LOW

Deep sleep settings. These pull from the substitions at the top of the YAML file. The `esp32_ext1_wakeup` is needed to get around the display not refreshing on its own.

    font:

This section provides all of the fonts, sizes, and glyphs used. You can find all of these fonts in the [font folder](https://github.com/lux4rd0/homeassistant/tree/main/esphome/fonts).

There are a few sections where I reference Google Fonts:

      - file: 'gfonts://Alef'
        id: font_humidity_percent_c
        glyphs:
          - '%'
        size: 36

This feature was provided in [ESPHome 2022.4.0](https://esphome.io/changelog/2022.4.0.html#google-fonts) - 20th April 2022. If you're using an older version of ESPHome - simply download the font from Google and refrence it in your file system.

    button:
      - platform: restart
        name: '${devicename} Restart'
        internal: false
      - platform: template
        name: '${devicename} Refresh'
        icon: 'mdi:update'
        on_press:
          then:
            - component.update: '${devicename}_display'
        internal: false

Provides for two buttons in Home Assistant to restart the device and refresh the display. Because I'm using three screens that are selected from Home Assistant, I wanted a way to refresh remotely. Originally had a refresh on drop down select, but it would cause the display to refresh twice. Once on button sensor refresh on wake and the other once all the day was loaded. However, since the display is usually in sleep mode, pressing buttons besides the wake or reset I decided to remove.

    binary_sensor:
      - platform: gpio
        pin:
          number: GPIO39
          inverted: true
        name: '${devicename} Button 1'
      - platform: gpio
        pin:
          number: GPIO34
          inverted: true
        name: '${devicename} Button 2'
        internal: false
      - platform: gpio
        pin:
          number: GPIO35
          inverted: true
        name: '${devicename} Button 3'
        internal: false
      - platform: homeassistant
        id: '${devicename}_prevent_deep_sleep'
        name: '${devicename} Prevent Deep Sleep'
        entity_id: 'input_boolean.${devicename}_prevent_deep_sleep'

These binary sensors provides for the ablity to use the three Lilygo buttons and send status back to Home Assistant. The 4th physical button isn't usable, and the 5th one is a reset. The `${devicename}_prevent_deep_sleep` provides status to know if the device knows if it should sleep or not.

    external_components:
      - source: 'github://ashald/esphome@lilygo-t5-47'
        components:
          - lilygo_t5_47
        refresh: 0s
      - source: github://pr#3577
        components: wifi
        refresh: 0s

These `external_components` provide the display driver for the Lilygo T5. The one I'm using is by [Borys Pierov](https://github.com/ashald).

More details on this display driver and others may be found in this ESPHome [Feature Request](https://github.com/esphome/feature-requests/issues/1109).

[PR#3577](https://github.com/esphome/esphome/pull/3577) is being used to reduce the amount of memory being used. Early deployments ran into [this problem](https://github.com/esphome/issues/issues/855#issue-524128559) (Core 1 Panic). This is used in combination with the newer framework versions in order to support the large number of Home Assistant sensors for WeatherFlow and the large JSON/Display Lamdas used for my screens.

    display:
      platform: lilygo_t5_47
      full_update_every: 1
      cycles_render: 40
      cycles_invert: 40
      id: '${devicename}_display'
      update_interval: never

Display configurations for the Lilygo T5 specific to `ashald/esphome@lilygo-t5-47`. Does a full refresh on each update and the update interval is set to never. We'll update the display manually once all of the data is loaded from Home Assistant.

      lambda: |-
          if (id(${devicename}_page).state == "A") {

This is the start of the display drawing - part of the display YAML stanza. It looks for an `input_select` entity so you can choose which page you want displayed. [Input Select](https://www.home-assistant.io/integrations/input_select/) is part of Home Assistant helpers and can be found in Devices & Services. This needs to be added manually and the Entity ID needs to match the devicename/sensor in ESPHome.

![enter image description here](https://labs.lux4rd0.com/wp-content/uploads/2022/06/lilygo_t5_input_select.png)

    sensor:
      - platform: wifi_signal
        name: '${devicename} WiFi Signal'
        id: '${devicename}_WiFi_Signal'
        update_interval: 60s
      - platform: uptime
        name: '${devicename} Uptime'
        update_interval: 60s
      - platform: debug
        free:
          name: '${devicename} Heap Free'
        block:
          name: '${devicename} Heap Max Block'
        loop_time:
          name: '${devicename} Loop Time'
      - id: '${devicename}_battery_voltage'
        name: '${devicename} Battery Voltage'
        platform: lilygo_t5_47
        unit_of_measurement: V
        state_class: measurement
        device_class: voltage
        update_interval: 60s

The Sensor section accounts for both sending and receiving data between ESPHome and Home Assistant. The first sensors report back Wi-Fi signal, uptime,  battery, and debug information. You can choose to remove update and debug if you don't want them reported. Both **Wi-Fi** and **Battery Voltage** are shown on the display. Battery Voltage is reported back from the `github://ashald/esphome@lilygo-t5-47` Display Driver. Remove the `name:` line if you don't want them reported to Home Asssitant.

Below those, you'll find the bulk of the Home Assistant sensors used to display data:

      - platform: homeassistant
        entity_id: sensor.bedroom_dave_bathroom_humidity_humidity
        id: bedroom_dave_bathroom_humidity_humidity
      - platform: homeassistant
        entity_id: sensor.bedroom_red_bathroom_humidity_humidity
        id: bedroom_red_bathroom_humidity_humidity

These should be updated to reflect whatever sensors you're using. Note, with changes in [ESPHome 2022.4.0](https://esphome.io/changelog/2022.4.0.html), the use of `internal: false` in the YAML configruation is no longer needed for `platform: homeassistant` sensors.

Take note on the last binary sensor is an `on_value:` line:

      - platform: homeassistant
        entity_id: sensor.weatherflow_hourly_forecast_23
        id: wf_h_fc_23_pxl
        attribute: pixel_height
        on_value:
          then:
            - logger.log: Received sensor.weatherflow_hourly_forecast_23
            - script.execute: all_data_received

This runs a script once the binary sensor has reported data from Home Assistant - essentially saying "Hey there!! All data has been received - start the manual display refresh..."

The next section are all of the text sensors:

    text_sensor:
      - platform: debug
        device:
          name: '${devicename} Device Info'
          id: '${devicename}_device_info'
      - platform: homeassistant
        entity_id: sensor.weatherflow_hourly_forecast_0
        id: wf_h_fc_0_precip_prob_icon
        attribute: precip_probability_icon

Here again, you can remove the debug sensor if you don't want it reporting back to Home Assistant. 

As mentioned earlier, refreshing on a change of pages from Home Assistant can be done with this last text_sensor:

      - platform: homeassistant
        entity_id: 'input_select.${devicename}_page'
        id: '${devicename}_page'
    #    on_value:
    #      then:
    #        - component.update: '${devicename}_display'

It's commented out here because I didn't like the double display update. But if you happen to skip the sleep and you want to have the display update when you change pages in Home Assistant, simply remove the comments.

The last part is the script to refresh the screen and either prevent deep sleep from happening, or enter deep sleep.

    script:
      - id: all_data_received
        then:
          - component.update: '${devicename}_display'
          - delay: 5s
          - if:
              condition:
                binary_sensor.is_on: '${devicename}_prevent_deep_sleep'
              then:
                - logger.log: 'Skipping sleep, per prevent_deep_sleep'
                - deep_sleep.prevent: deep_sleep_control
              else:
                - script.execute: enter_sleep
      - id: enter_sleep
        then:
          - if:
              condition:
                lambda: |-
                  auto time = id(ntp).now();
                  if (!time.is_valid()) { 
                    return false;
                  }
                  return (time.hour < 6); 
              then:
                - logger.log: 'Nighttime, entering long sleep for ${night_sleep_time}'
                - deep_sleep.enter:
                    id: deep_sleep_control
                    sleep_duration: '${night_sleep_time}'
              else:
                - logger.log: 'Daytime, entering short sleep for ${sleep_time}'
                - deep_sleep.enter:
                    id: deep_sleep_control
                    sleep_duration: '${sleep_time}'

You will need to define an [input_boolean](https://www.home-assistant.io/integrations/input_boolean/) that is part of Home Assistant helpers and can be found in Devices & Services. This needs to be added manually and the Entity ID needs to match the devicename/sensor in ESPHome.. 

![enter image description here](https://labs.lux4rd0.com/wp-content/uploads/2022/06/lilygo_t5_input_boolean.png)

If Prevent Deep Sleep is toggled on, the display will still refresh but will not go into deep sleep. This is useful if you want to manually change the display pages and refresh - or if you're needing to do a firmware upgrade. 

The script also checks to see what time it is. If it's nighttime (between midnight and 6am, it goes into an extended deep sleep as defined in the top substituion section. If it's not nighttime, it does a short sleep cycle, also defined in the top substituion section - currently configured for 15 minutes.

The display is only configured to refresh once the data is loaded - which is every time the Lilygo reboots or wakes from sleep. If it stays awake, you will need to either manually refresh the screen, set the display configuration to refresh at a specific interval, or wait for the last sensor to be refreshed on the Home Assistant server.
