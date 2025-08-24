//
//  wifi_config.c
//
//  * Workaround for accessing the `WIFI_INIT_CONFIG_DEFAULT()` macro from swift
//
//  greenhouse-monitor
//  Created by Joe Diragi on Aug 9, 2025
//

#include "BridgingHeader.h"

// -- Misc. Interop workarounds --

uint16_t portTickPeriodMS() { return portTICK_PERIOD_MS; }
uint16_t pdMSToTicks(const int ms) { return pdMSToTicks(ms); }

// extern "C" void LCD_Init_Wrapper() {
//     LCD_Init();
// }

// -- Logging --
// Required here because of c++ macro shenanigans

void logError(const char * tag, const char * str) {
  ESP_LOGE(tag, "%@", str);
}

void logInfo(const char* tag, const char* str) {
  ESP_LOGI(tag, "%@", str);
}

// Workaround for 'undefined reference to `swift_float64ToString`'
void logSensorStatus(const char* tag, float temp, float humid) {
  ESP_LOGI(tag, "Temperature: %f", temp);
  ESP_LOGI(tag, "Humidity: %f", humid);
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
