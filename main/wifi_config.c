//
//  wifi_config.c
//
//  * Workaround for accessing the `WIFI_INIT_CONFIG_DEFAULT()` macro from swift
//
//  greenhouse-monitor
//  Created by Joe Diragi on Aug 9, 2025
//

#include "BridgingHeader.h"
#include "esp_log.h"

// -- Misc. Interop workarounds --

wifi_init_config_t default_wifi_init_config() {
  wifi_init_config_t config = WIFI_INIT_CONFIG_DEFAULT();
  return config;
}

uint16_t portTickPeriodMS() { return portTICK_PERIOD_MS; }

// -- Logging --
// Required here because of c++ macro shenanigans

void logError(const char * tag, const char * str) {
  ESP_LOGE(tag, "%@", str);
}

void logInfo(const char* tag, const char* str) {
  ESP_LOGI(tag, "%@", str);
}

// void i2c_master_init() {
//   i2c_config_t conf = {
//     .mode = I2C_MODE_MASTER,
//     .sda_io_num = I2C_MASTER_SDA_IO,
//     .sda_pullup_en = GPIO_PULLUP_ENABLE,
//     .scl_io_num = I2C_MASTER_SCL_IO,
//     .scl_pullup_en = GPIO_PULLUP_ENABLE,
//     .master.clk_speed = I2C_MASTER_FREQ_HZ,
//   };

//   i2c_param_config(I2C_MASTER_NUM, &conf);
//   i2c_driver_install(I2C_MASTER_NUM, conf.mode, 0, 0, 0);
// }
