#ifndef __BRIDGINGHEADER_H
#define __BRIDGINGHEADER_H

#include <stdio.h>
#include <string.h>

#include "esp_wifi.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "nvs_flash.h"
#include "sdkconfig.h"

wifi_config_t wifi_configuration_base = {.sta = {
                                             .ssid = "The Game",
                                             .password = "Mufasa2090363!",
                                         }};

extern wifi_init_config_t default_wifi_init_config();

#endif
