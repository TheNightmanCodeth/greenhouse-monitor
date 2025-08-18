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
  _ = AHT20.initialize()

  while true {
    let data = AHT20.read()
    logBMP280Status("TAG", data.temp, data.humidity)
  }
  // I2C.masterInit()
}

