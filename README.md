# Greenhouse Monitor

A `swift-embedded` project for monitoring humidity and temperature levels in
ikea greenhouse cabinets

## Status

Builds, waiting for Amazon to deliver some things. [X] Connects to WiFi [ ]
Monitors Humidity [ ] Monitors Temperature [ ] Integrates with Matter/Zigbee

## Goals

idk

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
6. Run the build:
   `idf.py set-target esp32c6 && idf.py build`
7. Flash
   - (Host) Connect the board to your computer and start the serial server (requires esp-idf installation)
      `esp_rfc2217_server.py -v -p 4000 /dev/cu.usbmodem1101`
   - (Container) Flash the board (copy the rfc2217:// url from the output of the previous command):
      `idf.py flash -p rfc2217://$(your-host-ip):4000?ign_set_control monitor`

### Containerization (macOS)

WIP

### Local Build

First make sure you have swiftly setup with the latest nightly toolchain
installed. You might need to update `.swift-version` to match if a newer version
is available.

1. Setup ESP-IDF / ESP-Matter environment (`. $IDF_PATH/export.sh && . $ESP_MATTER_PATH/export.sh`)
2. Enter repository root (`cd greenhouse-monitor`)
3. Set idf target (`idf.py set-target esp32c6`)
4. Build (`idf.py build`)
5. Flash (`idf.py flash monitor`)

## Development

The quickest way to get going is via the devcontainer in vscode. Just open the project in vscode and open in dev container. It'll take a while to build the first time but then it just works

# Pairing

Once you've flashed the device, the default pairing code can be used to get goin:

34970112332