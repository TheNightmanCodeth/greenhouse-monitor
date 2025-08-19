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

enum Matter {}

extension Matter {
  class Node {
    var identifyHandler: (() -> Void)? = nil

    var endpoints: [Endpoint] = []

    func addEndpoint(_ endpoint: Endpoint) {
      endpoints.append(endpoint)
    }

    // swift-format-ignore: NeverUseImplicitlyUnwrappedOptionals
    // This is never actually nil after init(), and inside init we want to form a callback closure that references self.
    var innerNode: RootNode!

    init() {
      // Initialize persistent storage.
      nvs_flash_init()

      // For now, leak the object, to be able to use local variables to declare it. We don't expect this object to be created and destroyed repeatedly.
      _ = Unmanaged.passRetained(self)

      // Create the actual root node object, wire up callbacks.
      let root = RootNode(
        attribute: self.eventHandler,
        identify: { _, _, _, _ in self.identifyHandler?() })
      guard let root else {
        fatalError("Failed to setup root node.")
      }
      self.innerNode = root
    }

    func eventHandler(
      type: MatterAttributeEvent, endpoint: __idf_main.Endpoint,
      cluster: Cluster, attribute: UInt32,
      value: UnsafeMutablePointer<esp_matter_attr_val_t>?
    ) {
      guard type == .didSet else { return }
      guard let e = self.endpoints.first(where: { $0.id == endpoint.id }) else {
        return
      }
      let value: Int = Int(value?.pointee.val.u64 ?? 0)
      guard let a = Endpoint.Attribute(cluster: cluster, attribute: attribute)
      else { return }
      e.eventHandler?(Endpoint.Event(type: type, attribute: a, value: value))
    }
  }
}

extension Matter {
  class Endpoint {
    init(node: Node) {
      // For now, leak the object, to be able to use local variables to declare it. We don't expect this object to be created and destroyed repeatedly.
      _ = Unmanaged.passRetained(self)
    }

    var id: Int = 0

    var eventHandler: ((Event) -> Void)? = nil

    enum Attribute {
      case temperatureMeasurement
      case relativeHumidityMeasurement
      case unknown(UInt32)

      init?(cluster: Cluster, attribute: UInt32) {
        if cluster.as(TemperatureMeasurement.self) != nil {
            switch attribute {
                case TemperatureMeasurement.AttributeID<TemperatureMeasurement.CurrentTemperature>.state.rawValue: self = .temperatureMeasurement
                default: return nil
            }
        } else if cluster.as(RelativeHumidityMeasurement.self) != nil {
            switch attribute {
                case RelativeHumidityMeasurement.AttributeID<RelativeHumidityMeasurement.CurrentRelativeHumidity>.state.rawValue: self = .relativeHumidityMeasurement
                default: return nil
            }
        } else {
            self = .unknown(attribute)
        }
      }
    }

    struct Event {
      var type: MatterAttributeEvent
      var attribute: Attribute
      var value: Int
    }
  }
}

extension Matter {
    class TemperatureSensor: Endpoint {
        override init(node: Node) {
            super.init(node: node)
            var config =  esp_matter.endpoint.temperature_sensor.config()
            config.temperature_measurement.measured_value = .init(Int16(AHT20.read().temp))

            let node = MatterTemperatureSensor(
                node.innerNode, configuration: config)
            self.id = Int(node.id)
        }
    }

    class RelativeHumiditySensor: Endpoint {
        override init(node: Node) {
            super.init(node: node)
            var config = esp_matter.endpoint.humidity_sensor.config()
            config.relative_humidity_measurement.measured_value = .init(UInt16(AHT20.read().humidity))

            let node = MatterHumiditySensor(
                node.innerNode, configuration: config)
            
            self.id = Int(node.id)
        }
    }
}

extension Matter {
  class Application {
    var rootNode: Node? = nil

    init() {
      // For now, leak the object, to be able to use local variables to declare
      // it. We don't expect this object to be created and destroyed repeatedly.
      _ = Unmanaged.passRetained(self)
    }

    func start() {
      func callback(
        event: UnsafePointer<chip.DeviceLayer.ChipDeviceEvent>?, context: Int
      ) {
        // Ignore callback if event not set.
        guard let event else { return }
        switch Int(event.pointee.Type) {
        case chip.DeviceLayer.DeviceEventType.kFabricRemoved:
          recomissionFabric()
        default: break
        }
      }
      esp_matter.start(callback, 0)
      
    }
  }
}

func print(_ a: Matter.Endpoint.Attribute) {
  switch a {
  case .temperatureMeasurement: print("Temperature")
  case .relativeHumidityMeasurement: print("Relative Humidity")
  case .unknown: print("unknown")
  }
}