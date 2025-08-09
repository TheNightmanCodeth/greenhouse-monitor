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
  print("Hello from Swift on ESP32-C6!")
  print("")
  nvs_flash_init()

  let wifiManager = WifiManager(ssid: "The Game", password: "Mufasa2090363!") { handler, base, id, data in
    if id == WIFI_EVENT_STA_START.rawValue {
      print("Wifi connecting...")
    } else if id == WIFI_EVENT_STA_CONNECTED.rawValue {
      print("Wifi connected")
    } else if id == WIFI_EVENT_STA_DISCONNECTED.rawValue {
      print("Wifi disconnected")
    } else if id == IP_EVENT_STA_GOT_IP.rawValue {
      print("wifi got ip...")
    }
  }

  wifiManager.connect()

  while true {
    print("Runloop start")
  }
}

