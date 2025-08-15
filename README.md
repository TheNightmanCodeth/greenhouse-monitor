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

There are 2 ways to build the firmware. Either with the host tools installed on
your local machine, or with the included dockerfile

### Docker

1. Build the image: `docker build . --tag greenhouse-monitor-builder`
2. Install esptool on your host for flashing:
   `python3 -m pip install esptool --user`
3. Find your attached microcontroller (
   - on macOS it usually attaches on /dev/cu.usbserial-10:
     `ls /dev/cu.usbserial-*`
   - on linux it usually attaches on /dev/ttyUSB0: `ls /dev/ttyUSB*`
4. Run the serial server:
   `esp_rfc2217_server.py -v -p 4000 /dev/cu.usbserial-10`
5. Launch the docker container:
   `docker run -it --cpus 4 --memory 8G -v .:/code:z greenhouse-monitor-builder`

### Containerization (macOS)

You can also use the new `container` tool on macOS >= 26

1. Start the container service: `container system start`
2. Build the image:
   `container build --tag greenhouse-monitor-builder --file Dockerfile .`
3. ???

### Local Build

First make sure you have swiftly setup with the latest nightly toolchain
installed. You might need to update `.swift-version` to match if a newer version
is available.

1. Setup ESP-IDF (`. $IDF_PATH/export.sh`)
2. Enter repository root (`cd greenhouse-monitor`)
3. Set idf target (`idf.py set-target esp32c6`)
4. Build (`idf.py build`)
5. Flash (`idf.py flash`)
