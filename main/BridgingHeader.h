#ifndef __BRIDGINGHEADER_H
#define __BRIDGINGHEADER_H

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "driver/i2c.h"
#include "esp_log.h"
#include "esp_wifi.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "nvs_flash.h"
#include "sdkconfig.h"

// -- Misc. interop workarounds --
extern wifi_init_config_t default_wifi_init_config();
extern uint16_t portTickPeriodMS();

// -- Logging --
void logError(const char* tag, const char* str);
void logInfo(const char* tag, const char* str);

#define I2C_MASTER_NUM I2C_NUM_0
#define I2C_MASTER_SDA_IO 21
#define I2C_MASTER_SCL_IO 22
#define I2C_MASTER_FREQ_HZ 100000
#define BMP280_ADDR 0x76

// BMP280 Register Addresses
#define BMP280_REG_ID 0xD0
#define BMP280_REG_RESET 0xE0
#define BMP280_REG_STATUS 0xF3
#define BMP280_REG_CTRL_MEAS 0xF4
#define BMP280_REG_CONFIG 0xF5
#define BMP280_REG_PRESS_MSB 0xF7
#define BMP280_REG_CALIB_START 0x88

// BMP280 Configuration Values
#define BMP280_CHIP_ID 0x58
#define BMP280_RESET_VALUE 0xB6
#define BMP280_NORMAL_MODE 0x03
#define BMP280_OSRS_T_16X (0x05 << 5)
#define BMP280_OSRS_P_16X (0x05 << 2)
#define BMP280_FILTER_COEFF_16 (0x04 << 2)
#define BMP280_STANDBY_500MS (0x04 << 5)

#endif
