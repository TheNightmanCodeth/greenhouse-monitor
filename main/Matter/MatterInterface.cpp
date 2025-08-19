//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#include "BridgingHeader.h"
#include "platform/CHIPDeviceLayer.h"
#include <cstdint>

esp_err_t esp_matter::attribute::set_callback_shim(callback_t_shim callback) {
  return set_callback((callback_t)callback);
}

esp_matter::cluster_t *esp_matter::cluster::get_shim(esp_matter::endpoint_t *endpoint, unsigned int cluster_id) {
  return get(endpoint, (uint32_t)cluster_id);
}

esp_matter::attribute_t *esp_matter::attribute::get_shim(esp_matter::cluster_t *cluster, unsigned int attribute_id) {
  return get(cluster, (uint32_t)attribute_id);
}

void tempSensorNotification(unsigned int endpoint_id, float temp) {
  chip::DeviceLayer::SystemLayer().ScheduleLambda([endpoint_id, temp]() {
    esp_matter::attribute_t * attribute = esp_matter::attribute::get(endpoint_id, 
                                             chip::app::Clusters::TemperatureMeasurement::Id, 
                                             chip::app::Clusters::TemperatureMeasurement::Attributes::MeasuredValue::Id);
    esp_matter_attr_val_t val = esp_matter_invalid(NULL);
    esp_matter::attribute::get_val(attribute, &val);
    val.val.i16 = static_cast<int16_t>(temp);
    esp_matter::attribute::update(endpoint_id, 
                      chip::app::Clusters::TemperatureMeasurement::Id, 
                      chip::app::Clusters::TemperatureMeasurement::Attributes::MeasuredValue::Id, &val);
  });
}

void humiditySensorNotification(unsigned int endpoint_id, float humidity) {
  chip::DeviceLayer::SystemLayer().ScheduleLambda([endpoint_id, humidity]() {
    esp_matter::attribute_t * attribute = esp_matter::attribute::get(endpoint_id,
                                                                     chip::app::Clusters::RelativeHumidityMeasurement::Id,
                                                                     chip::app::Clusters::RelativeHumidityMeasurement::Attributes::MeasuredValue::Id);
    esp_matter_attr_val_t val = esp_matter_invalid(NULL);
    esp_matter::attribute::get_val(attribute, &val);
    val.val.i16 = static_cast<int16_t>(humidity);
    esp_matter::attribute::update(endpoint_id,
                                  chip::app::Clusters::RelativeHumidityMeasurement::Id,
                                  chip::app::Clusters::RelativeHumidityMeasurement::Attributes::MeasuredValue::Id, &val);
  });
}

void recomissionFabric() {
  if (chip::Server::GetInstance().GetFabricTable().FabricCount() == 0) {
    chip::CommissioningWindowManager & commissionMgr = chip::Server::GetInstance().GetCommissioningWindowManager();
    constexpr auto kTimeoutSeconds = chip::System::Clock::Seconds16(300);
    if (!commissionMgr.IsCommissioningWindowOpen()) {
      commissionMgr.OpenBasicCommissioningWindow(kTimeoutSeconds, chip::CommissioningWindowAdvertisement::kDnssdOnly);
    }
  }
}