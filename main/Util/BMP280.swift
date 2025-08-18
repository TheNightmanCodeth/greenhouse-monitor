enum BMP280 {
  static func initialize() -> esp_err_t {
    var chipID: UInt8 = .init()
    var ret = I2C.masterWriteReadDevice(&chipID)

    guard ret == ESP_OK else {
      logError("BMP280", "Failed to read chip ID")
      return ret
    }

    guard chipID == BMP280_CHIP_ID else {
      logError("BMP280", "Invalid chip ID: \(chipID) (expected \(BMP280_CHIP_ID))")
      return ESP_ERR_INVALID_RESPONSE
    }

    logInfo("BMP280", "BMP280 detected (ID: \(chipID))")

    // Soft reset the sensor
    var resetCommand: [UInt8] = [BMP280_REG_RESET, BMP280_RESET_VALUE].map(UInt8.init)
    ret = I2C.masterWriteToDevice(&resetCommand)
    guard ret == ESP_OK else {
      logError("BMP280", "Failed to reset sensor")
      return ret
    }

    vTaskDelay(100 / UInt32(portTickPeriodMS())) // Wait for reset to complete

    // Configure sensor: Normal mode, 16x oversampling for both temp and pressure
    var ctrlMeasurementCommand: [UInt8] = [BMP280_REG_CTRL_MEAS, (BMP280_OSRS_T_16X | BMP280_OSRS_P_16X | BMP280_NORMAL_MODE)].map(UInt8.init)
    ret = I2C.masterWriteToDevice(&ctrlMeasurementCommand)
    guard ret == ESP_OK else {
      logError("BMP280", "Failed to configure measurement register")
      return ret
    }

    // Configure filter and standby time
    var filterStdbyCommand: [UInt8] = [BMP280_REG_CONFIG, BMP280_STANDBY_500MS | BMP280_FILTER_COEFF_16].map(UInt8.init)
    ret = I2C.masterWriteToDevice(&filterStdbyCommand)
    guard ret == ESP_OK else {
      logError("BMP280", "Failed to configure config register")
      return ret
    }

    // Read calibration data
    ret = Calibration.calibrate()
    guard ret == ESP_OK else { return ret }

    logInfo("BMP280", "BMP280 Initialized successfully")
    return ESP_OK
  }

  static func read() -> (temp: Float, humidity: Float) {
    var data: [UInt8] = .init()
    let ret = I2C.masterWriteReadDevice(&data, register: BMP280_REG_PRESS_MSB, writeSize: 1, readSize: 6)
    guard ret == ESP_OK else {
      logError("BMP280", "Failed to read sensor data: \(ret)")
      return (0,0)
    }

    // Extract individual values from data
    let adcPressure = (Int32(data[0]) << 12) | (Int32(data[1]) << 4) | (Int32(data[2]) >> 4)
    let adcTemperature = (Int32(data[3]) << 12) | (Int32(data[4]) << 4) | (Int32(data[5]) >> 4)

    // Compensate results using calibration values
    let temperature = Calibration.compensateTemperature(adcTemperature, units: .fahrenheit)
    let pressure = Calibration.compensatePressure(adcPressure)
    return (temperature, pressure)
  }
}

// MARK: BMP280 + Calibration

extension BMP280 {
  struct Calibration {
    private(set) static var calibration: Results = .init()
    static let calibrationRegisterStart: UInt8 = 0x88

    enum Units {
      enum Temperature: UInt8 {
        case celsius
        case fahrenheit
      }
    }

    /// Compensates temperature data according to BMP280 datasheet
    /// - Parameter temp: The temperature value received from the BMP280
    /// - Parameter units: The units (fahrenheit or celsius) to return (default celsius)
    /// - Returns: The compensated temperature value (in `units`)
    static func compensateTemperature(_ temp: Int32, units: Units.Temperature = .celsius) -> Float {
      let compA = (((temp >> 3) - (Int32(calibration.digT1) << 1)) * (Int32(calibration.digT2))) >> 11
      let compB = (((((temp >> 4) - Int32(calibration.digT1))^2) >> 12) * (Int32(calibration.digT3))) >> 14
      calibration.fine = compA + compB
      let celsius = Float(((calibration.fine * 5 + 128) >> 8) / 100)

      return switch units {
        case .celsius: celsius
        case .fahrenheit: (celsius * 9/5) + 32
      }
    }

    static func compensatePressure(_ pressure: Int32) -> Float {
      var compA = Int64(calibration.fine) - 128000
      var compB = compA * compA * Int64(calibration.digP6)
      compB = compB + ((compA * Int64(calibration.digP5)) << 17)
      compB = compB + (Int64(calibration.digP4) << 35)
      compA = ((compA * compA * Int64(calibration.digP3)) >> 8) + ((compA * Int64(calibration.digP2)) << 12)
      compA = ((1 << 47) + compA) * (Int64(calibration.digP1) >> 33)

      guard compA != 0 else { return 0 } // Don't divide by 0

      var p: Int64 = .init(1048576 - pressure)
      p = (((p << 31) - compB) * 3125) / compA
      compA = (Int64(calibration.digP9) * (p >> 13) * (p >> 13)) >> 25
      compB = (Int64(calibration.digP8) * p) >> 19
      p = ((p + compA + compB) >> 8) + (Int64(calibration.digP7) << 4)
      return Float(p) / 25600.0 // Pressure in hPa
    }

    static func calibrate() -> esp_err_t {
      var data: [UInt8] = .init()
      let ret = I2C.masterWriteReadDevice(&data, register: BMP280_REG_CALIB_START, writeSize: 1, readSize: 24)

      guard ret == ESP_OK else {
        logError("BMP280", "Failed to load calibration data")
        return ret
      }

      calibration = extractCalibrationValues(from: data)

      return ret
    }

    static func extractCalibrationValues(from data: [UInt8]) -> Results {
      .init(
        digT1: .init((data[1] << 8) | data[0]),
        digT2: .init((data[3] << 8) | data[2]),
        digT3: .init((data[5] << 8) | data[4]),
        digP1: .init((data[7] << 8) | data[6]),
        digP2: .init((data[9] << 8) | data[8]),
        digP3: .init((data[11] << 8) | data[10]), 
        digP4: .init((data[13] << 8) | data[12]), 
        digP5: .init((data[15] << 8) | data[14]), 
        digP6: .init((data[17] << 8) | data[16]), 
        digP7: .init((data[19] << 8) | data[18]), 
        digP8: .init((data[23] << 8) | data[22]), 
        digP9: .init((data[21] << 8) | data[20]), 
        fine: 0
      )
    }

    /// Holder type for calibration results
    struct Results {
      let digT1: Int16
      let digT2: Int16
      let digT3: Int16
      let digP1: UInt16
      let digP2: Int16
      let digP3: Int16
      let digP4: Int16
      let digP5: Int16
      let digP6: Int16
      let digP7: Int16
      let digP8: Int16
      let digP9: Int16
      var fine: Int32 // Carries fine temperature value for pressure calculation
    }
  }
}

// Empty init
extension BMP280.Calibration.Results {
  init() {
    self.digT2 = .init()
    self.digT1 = .init()
    self.digT3 = .init()
    self.digP1 = .init()
    self.digP2 = .init()
    self.digP3 = .init()
    self.digP4 = .init()
    self.digP5 = .init()
    self.digP6 = .init()
    self.digP7 = .init()
    self.digP8 = .init()
    self.digP9 = .init()
    self.fine = .init()
  }
}

extension Numeric {
  func convert(from: BMP280.Calibration.Units.Temperature, to: BMP280.Calibration.Units.Temperature) -> Self {
    guard from != to else { return self }
    return switch from {
      case .celsius: (self * Self(exactly: 9/5)!) + 32
      case .fahrenheit: (self - 32) * Self(exactly: 5/9)!
    }
  }
}