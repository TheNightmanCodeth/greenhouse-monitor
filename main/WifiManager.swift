//
//  WifiManager.swift
//
//  * Initializes and manages wifi connection
//
//  greenhouse-monitor
//  Created by Joe Diragi on Aug 9, 2025
//

struct WifiManager {
  let ssid: String
  let password: String
  var eventHandler: esp_event_handler_t

  init(ssid: String, password: String, _ eventHandler: esp_event_handler_t) {
    self.ssid = ssid
    self.password = password
    self.eventHandler = eventHandler
  }

  func connect() {
    esp_netif_init()
    esp_event_loop_create_default()
    esp_netif_create_default_wifi_sta()
    var initConfig = default_wifi_init_config()
    esp_wifi_init(&initConfig)
    esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, eventHandler, nil)

    var config = makeWifiConfig()
    esp_wifi_set_config(WIFI_IF_STA, &config)
    esp_wifi_start()
    esp_wifi_set_mode(WIFI_MODE_STA)
    esp_wifi_connect()
  }

  func makeWifiConfig() -> wifi_config_t {
    var wifiConfig: wifi_config_t = .init()
    ssid.withCString { ssid in
      _ = withUnsafeMutableBytes(of: &wifiConfig.sta.ssid) { dest in
        strncpy(dest.bindMemory(to: CChar.self).baseAddress!, ssid, dest.count - 1)
      }
    }
    password.withCString { password in
      _ = withUnsafeMutableBytes(of: &wifiConfig.sta.password) { dest in
        strncpy(dest.bindMemory(to: CChar.self).baseAddress!, password, dest.count - 1)
      }
    }
    return wifiConfig
  }
}
