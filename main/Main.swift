//
//  Main.swift
//
//  * Application entrypoint and runloop
//  * Initializes system and sends updates on a static interval
//
//  greenhouse-monitor
//  Created by Joe Diragi on Aug 9, 2025
//

@_cdecl("app_main")
func main() {
  let pollInterval: UInt32 = 2000
  let tag = "GREENHOUSE_MONITOR"

  logInfo(tag, "Initializing I2C...")
  I2C.masterInit()

  logInfo(tag, "Initializing BMP280...")
  guard BMP280.initialize() == ESP_OK else {
    logError(tag, "Failed to initialize BMP280")
    return
  }

  logInfo(tag, "Starting temp/humidity measurement")

  while true {
    let measurement = BMP280.read()
    logBMP280Status(tag, measurement.temp, measurement.humidity)
    // logInfo(tag, "Temperature: \(Double(measurement.temp))")
    // logInfo(tag, "Humidity: \(Double(measurement.humidity))")
    vTaskDelay(pollInterval / UInt32(portTickPeriodMS()))
  }
}

