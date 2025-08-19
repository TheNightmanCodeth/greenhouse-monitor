#ifndef __BRIDGINGHEADER_H
#define __BRIDGINGHEADER_H

#include <cstdint>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <sdkconfig.h>
#include <nvs_flash.h>
#include <device.h>
#include <aht20.h>

#include <esp_log.h>

#define CONFIG_MBEDTLS_HKDF_C 1
#define CHIP_HAVE_CONFIG_H 1
#define CHIP_USE_ENUM_CLASS_FOR_IM_ENUM 1
#define CHIP_ADDRESS_RESOLVE_IMPL_INCLUDE_HEADER <lib/address_resolve/AddressResolve_DefaultImpl.h>

// There seems to be assumption in FabricTable.h that strnlen is implicitly available via some other headers, but that
// turns out to not be the case when importing these headers in Swift. Let's manually declare strnlen as a workaround.
//
// connectedhomeip/src/credentials/FabricTable.h:82:69: error: use of undeclared identifier 'strnlen'
extern "C" size_t strnlen(const char *s, size_t maxlen);
// esp-matter/components/esp_matter/esp_matter_client.h:57:26: error: use of undeclared identifier 'strdup'
extern "C" char *strdup(const char *s1);

#include <esp_matter.h>
#include <esp_matter_cluster.h>
#include <app-common/zap-generated/ids/Clusters.h>
#include <app/server/Server.h>

#include "Matter/MatterInterface.h"

// -- Misc. interop workarounds --
extern uint16_t portTickPeriodMS();

// -- Logging --
void logError(const char* tag, const char* str);
void logInfo(const char* tag, const char* str);
void logSensorStatus(const char* tag, float temp, float humid);

#define I2C_MASTER_NUM I2C_NUM_0
#define I2C_MASTER_SDA_IO 21
#define I2C_MASTER_SCL_IO 22
#define I2C_MASTER_FREQ_HZ 100000

#endif
