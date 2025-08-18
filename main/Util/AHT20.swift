enum AHT20 {
    private(set) static var bus: i2c_bus_handle_t!
    private(set) static var handle: aht20_dev_handle_t!

    static func initialize() -> esp_err_t {
        initI2C()

        var config = aht20_i2c_config_t.init(bus_inst: bus, i2c_addr: UInt8(AHT20_ADDRRES_0))
        var handle: aht20_dev_handle_t?
        let res = withUnsafeMutablePointer(to: &handle) { ptr in
            aht20_new_sensor(&config, ptr)
        }
        guard let handle, res == ESP_OK else {
            logError("AHT20", "Failed to initialize sensor")
            return res
        }

        Self.handle = handle

        return ESP_OK
    }

    static func initI2C() {
        let conf: i2c_config_t = i2c_config_t.init(
            mode: I2C_MODE_MASTER, 
            sda_io_num: I2C_MASTER_SDA_IO, 
            scl_io_num: I2C_MASTER_SCL_IO,
            sda_pullup_en: true,
            scl_pullup_en: true, 
            master: .init(clk_speed: UInt32(I2C_MASTER_FREQ_HZ)), 
            clk_flags: 0)

        withUnsafePointer(to: conf) { ptr in
            bus = i2c_bus_create(I2C_NUM_0, ptr)
        }
    }

    static func read() -> (temp: Float, humidity: Float) {
        var temp_raw: UInt32 = .init()
        var humi_raw: UInt32 = .init()
        var temp: Float = .init()
        var humi: Float = .init()
        aht20_read_temperature_humidity(handle, &temp_raw, &temp, &humi_raw, &humi)
        return (temp: temp, humidity: humi)
    }

    static func cleanup() {
        aht20_del_sensor(handle)
        i2c_bus_delete(&bus)
    }
}