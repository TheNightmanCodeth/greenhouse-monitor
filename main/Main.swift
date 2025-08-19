//
//  Main.swift
//
//  * Application entrypoint and runloop
//  * Initializes system and sends updates on a static interval
//
//  greenhouse-monitor
//  Created by Joe Diragi on Aug 9, 2025
//

func logEndpoint(_ name: String, event: Matter.Endpoint.Event) {
  print("    * \(name) endpoint handler:")
  print("      - Attr: \(event.attribute)")
  print("      - Value: \(event.value)")
}

@_cdecl("app_main")
func main() {
  let pollInterval: UInt32 = 2000
  let tag = "GREENHOUSE_MONITOR"
  
  print(" * Initializing Sensors")
  _ = AHT20.initialize()

  // (1) Create Matter root node
  let rootNode = Matter.Node()
  rootNode.identifyHandler = {
    print("Identify!")
  }

  // (2) Create a Temperature endpoint
  let tempEndpoint = Matter.TemperatureSensor(node: rootNode)
  tempEndpoint.eventHandler = { event in
    logEndpoint("Temperature", event: event)
  }

  // (3) Add the endpoint to the node
  rootNode.addEndpoint(tempEndpoint)

  // (4) Create a humidity endpoint
  let humiEndpoint = Matter.RelativeHumiditySensor(node: rootNode)
  humiEndpoint.eventHandler = { event in
    logEndpoint("Humidity", event: event)
  }

  // (5) Add the endpoint to the node
  rootNode.addEndpoint(humiEndpoint)

  // (6) Provide the node to a Matter application and start it
  let app = Matter.Application()
  app.rootNode = rootNode
  print("Starting matter")
  app.start()

  print("Starting sensor pollers")
  while true {
    let data = AHT20.read()
    
    tempSensorNotification(UInt32(tempEndpoint.id), data.temp)
    humiditySensorNotification(UInt32(humiEndpoint.id), data.humidity)

    logSensorStatus(tag, data.temp, data.humidity)
    vTaskDelay(pollInterval / UInt32(portTickPeriodMS()))
  }
}

