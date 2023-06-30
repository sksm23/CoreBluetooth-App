//
//  FoundPeripheral.swift
//  CoreBluetooth-App
//
//  Created by Sunil Kumar on 15/02/23.
//

import CoreBluetooth

class FoundPeripheral: Identifiable {
  var id: UUID
  var peripheral: CBPeripheral
  var name: String
  var advertisementData: [String : Any]
  var rssi: Int
  var discoverCount: Int
  
  init(_peripheral: CBPeripheral,
       _name: String,
       _advData: [String : Any],
       _rssi: NSNumber,
       _discoverCount: Int) {
    id = UUID()
    peripheral = _peripheral
    name = _name
    advertisementData = _advData
    rssi = _rssi.intValue
    discoverCount = _discoverCount + 1
  }
}
