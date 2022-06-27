

**WeatherFlow - Lilygo T5 4.7" Screen**

[lilygo_t5_clock.yaml](https://github.com/lux4rd0/homeassistant/blob/main/esphome/lilygo_t5_clock.yaml)

A simple clock that provides the current hour:minute on screen refresh:

![enter image description here](https://labs.lux4rd0.com/wp-content/uploads/2022/06/lilygo_t5_Clock-300x168.png)

More details may be found on my [ESPHome E Ink](https://labs.lux4rd0.com/home-assistant/esphome/e-ink-display/) blog.

YAML file details:

    substitutions:
      devicename: clock_display
      run_time: 1min
      sleep_time: 55s
      night_sleep_time: 375min

Provides for device name substitution. Any common sensors, buttons, switches, etc. - get swapped in for this name. I usually use the hostname. run_time and sleep_time are for the intervals providing for deep sleep. Night Sleep Time is for the 6 hours set for overnight sleep. Usually, this would be 360 minutes for 6 hours, but there's a fair amount of system clock drift during sleep - so I set this just over the 360 minutes so it doesn't get stuck when it wakes up in the morning.

    esp32:
      board: m5stack-core2

The Lilygo T5 isn't in the official [esp32 board list](https://registry.platformio.org/platforms/platformio/espressif32/boards) yet, but the [m5stack-core2](https://docs.platformio.org/en/latest/boards/espressif32/m5stack-core2.html) has the same configurations. This helps with the 16MB Flash 8MB PSRAM. 

    wifi:
      ssid: !secret wifi_ssid
      password: !secret wifi_password
      ap:
        ssid: '${devicename}'
        password: !secret wifi_password
      domain: .tylephony.com
      power_save_mode: none

This most likely can be what you've already templated with your ESPhome. Just using secrets files and domain names to help find my devices more consistently.

    deep_sleep:
      run_duration: '${run_time}'
      sleep_duration: '${sleep_time}'
      id: deep_sleep_control
      esp32_ext1_wakeup:
        pins: GPIO39
        mode: ALL_LOW

Deep sleep settings. These pull from the substitutions at the top of the YAML file. The `esp32_ext1_wakeup` is needed to get around the display not refreshing on its own.

    font:
      - file: fonts/Black Gladiator.ttf
        id: font_time
        glyphs:
          - 0
          - 1
          - 2
          - 3
          - 4
          - 5
          - 6
          - 7
          - 8
          - 9
          - ' '
          - ':'
          - A
          - M
          - P
        size: 440

This section provides the fonts, size, and glyphs used. You can find this font in the [font folder](https://github.com/lux4rd0/homeassistant/tree/main/esphome/fonts).

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

Provides two buttons in Home Assistant to restart the device and refresh the display. Because I'm using three screens selected from Home Assistant, I wanted a way to refresh remotely. Initially had a refresh on drop-down select, but it would cause the display to refresh twice. Once on button sensor refresh on wake and the other once all the day was loaded. However, since the display is usually in sleep mode, pressing buttons beside the wake or reset, I decided to remove it.

    external_components:
      - source: 'github://ashald/esphome@lilygo-t5-47'
        components:
          - lilygo_t5_47
        refresh: 0s

These `external_components` provide the display driver for the Lilygo T5. I'm using the one by [Borys Pierov](https://github.com/ashald).

More details on this display driver and others may be found in this ESPHome [Feature Request](https://github.com/esphome/feature-requests/issues/1109).

    display:
      platform: lilygo_t5_47
      full_update_every: 1
      cycles_render: 40
      cycles_invert: 40
      id: '${devicename}_display'
      update_interval: never
      lambda: |-
        it.strftime(480, 270, id(font_time), TextAlign::CENTER, "%I:%M",id(ntp).now());

Display configurations for the Lilygo T5 specific to `ashald/esphome@lilygo-t5-47`. Does a complete refresh on each update, and the update interval is set to never. We'll update the display manually once all the data is loaded from Home Assistant.

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



The Sensor section accounts for sending and receiving data between ESPHome and Home Assistant. The first sensors report Wi-Fi signal, uptime,  battery, and debug information. You can choose to remove update and debug if you don't want them reported. Both **Wi-Fi** and **Battery Voltage** are shown on the display. Battery Voltage is reported from the `github://ashald/esphome@lilygo-t5-47` Display Driver. Remove the `name:` line if you don't want them reported to Home Asssitant.

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
        on_value:
          then:
            - logger.log: 'Received input_select.${devicename}_page'
            - script.execute: all_data_received

These binary sensors provide the ability to use the three Lilygo buttons and send status back to Home Assistant. The 4th physical button isn't usable, and the 5th one is a reset. The `${devicename}_prevent_deep_sleep` provides status to know if the device knows if it should sleep or not. This runs a script once the binary sensor has reported data from Home Assistant - essentially saying, "Hey there!! All data has been received - start the manual display refresh..."

The following section is all of the text sensors:

    text_sensor:
      - platform: debug
        device:
          name: '${devicename} Device Info'
          id: '${devicename}_device_info'

Here again, you can remove the debug sensor if you don't want it reporting back to Home Assistant. 

The last part is the script to refresh the screen and either prevent deep sleep from happening or enter deep sleep.

    script:
      - id: all_data_received
        then:
          - component.update: '${devicename}_display'
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
                - logger.log: 'Daytime, entering short sleep for sleepSeconds'
                - lambda: |-
                    auto currentSeconds = id(ntp).now();
                    int sleepSeconds = (60 - currentSeconds.second) * 1000;
                    ESP_LOGI("sleepSeconds", "sleepSeconds");
                    id(deep_sleep_control).set_sleep_duration(sleepSeconds);
                - deep_sleep.enter:
                    id: deep_sleep_control
                
You will need to define an [input_boolean](https://www.home-assistant.io/integrations/input_boolean/) that is part of Home Assistant helpers and can be found in Devices & Services. This needs to be added manually, and the Entity ID must match the devicename/sensor in ESPHome. 

![enter image description here](https://labs.lux4rd0.com/wp-content/uploads/2022/06/lilygo_t5_input_boolean.png)

If Prevent Deep Sleep is toggled on, the display will still refresh but not go into a deep sleep. This is useful if you want to change the display pages and refresh them manually - or if you need to do a firmware upgrade. 

The script also checks to see what time it is. If it's nighttime (between midnight and 6 am, it goes into an extended deep sleep as defined in the top substitution section. If it's not nighttime, it does a short sleep cycle, also described in the top substitution section - currently configured for 15 minutes.

The display is only configured to refresh once the data is loaded - every time the Lilygo reboots or wakes from sleep. If it stays awake, you will need to manually refresh the screen, set the display configuration to refresh at a specific interval, or wait for the last sensor to be refreshed on the Home Assistant server.
