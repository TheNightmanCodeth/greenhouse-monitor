enum I2C {
    static func masterInit() {
        let conf: i2c_config_t = .init(
            mode: I2C_MODE_MASTER, 
            sda_io_num: I2C_MASTER_SDA_IO, 
            scl_io_num: I2C_MASTER_SCL_IO, 
            sda_pullup_en: true, 
            scl_pullup_en: true, 
            .init(master: .init(clk_speed: UInt32(I2C_MASTER_FREQ_HZ))), 
            clk_flags: 0
        )

        withUnsafePointer(to: conf) { ptr in
            i2c_param_config(I2C_NUM_0, ptr)
            i2c_driver_install(I2C_NUM_0, conf.mode, 0, 0, 0)
        }
    }

    static func masterWriteToDevice(_ input: inout [UInt8]) -> esp_err_t {
        withUnsafePointer(to: &input) { ptr in
            i2c_master_write_to_device(I2C_NUM_0, UInt8(BMP280_ADDR), ptr, 2, 1000 / UInt32(portTickPeriodMS()))
        }
    }

    static func masterWriteReadDevice(_ result: inout UInt8) -> esp_err_t {
        withUnsafeMutablePointer(to: &result) { ptr in
            var reg = UInt8(BMP280_REG_ID)
            return withUnsafePointer(to: &reg) { reg in
                i2c_master_write_read_device(I2C_NUM_0, .init(BMP280_ADDR), reg, 1, ptr, 1, 1000 / UInt32(portTickPeriodMS()))
            }
        }
    }

    static func masterWriteReadDevice(_ result: inout [UInt8], register: Int32, writeSize: Int = 1, readSize: Int = 6) -> esp_err_t {
        withUnsafeMutablePointer(to: &result) { ptr in
            var reg = UInt8(register)
            return withUnsafePointer(to: &reg) { reg in
                i2c_master_write_read_device(I2C_NUM_0, .init(BMP280_ADDR), reg, writeSize, ptr, readSize, 1000 / UInt32(portTickPeriodMS()))
            }
        }
    }
}