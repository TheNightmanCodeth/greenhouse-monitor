# Greenhouse Monitor

A `swift-embedded` project for monitoring humidity and temperature levels in
ikea greenhouse cabinets

## Status

Builds, waiting for Amazon to deliver some things. [X] Connects to WiFi [ ]
Monitors Humidity [ ] Monitors Temperature [ ] Integrates with Matter/Zigbee

## Goals

I don't even know what I'm doing with this yet.

I think I'd like to have a zigbee network of humidity/temp monitors which
communicate with an rpi responsible for toggling humidifiers, lights, heatmats,
etc.

## Building

First make sure you have swiftly setup with the latest nightly toolchain
installed. You might need to update `.swift-version` to match if a newer version
is available.

1. Setup ESP-IDF (`. $IDF_PATH/export.sh`)
2. Enter repository root (`cd greenhouse-monitor`)
3. Set idf target (`idf.py set-target esp32c6`)
4. Build (`idf.py build`)
5. Flash (`idf.py flash`)
