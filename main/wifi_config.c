//
//  wifi_config.c
//
//  * Workaround for accessing the `WIFI_INIT_CONFIG_DEFAULT()` macro from swift
//
//  greenhouse-monitor
//  Created by Joe Diragi on Aug 9, 2025
//

#include "BridgingHeader.h"

wifi_init_config_t default_wifi_init_config() {
  wifi_init_config_t config = WIFI_INIT_CONFIG_DEFAULT();
  return config;
}
