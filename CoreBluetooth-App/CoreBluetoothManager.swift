//
//  CoreBluetoothManager.swift
//  CoreBluetooth-App
//
//  Created by Sunil Kumar on 30/01/23.
//

import CoreBluetooth

class CoreBluetoothManager: NSObject, ObservableObject {
  
  @Published var isBlePower: Bool = false
  @Published var isSearching: Bool = false
  @Published var isConnected: Bool = false
  
  @Published var foundPeripherals: [FoundPeripheral] = []
  @Published var foundServices: [FoundService] = []
  @Published var foundCharacteristics: [FoundCharacteristic] = []
  
  @Published var readData: String = ""
  @Published var notifiedData: String = ""

  private var centralManager: CBCentralManager!
  private var connectedPeripheral: CBPeripheral!
  
  private let serviceUUID: CBUUID = CBUUID()
  
  override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self,
                                      queue: nil,
                                      options: [CBCentralManagerOptionShowPowerAlertKey: true])
  }
  
  // MARK: - Control Functions
  
  func startScan() {
    let scanOption = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
    centralManager?.scanForPeripherals(withServices: nil,
                                       options: scanOption)
    print("# Start Scan")
    isSearching = true
  }
  
  func stopScan() {
    centralManager.stopScan()
    print("# Stop Scan")
    isSearching = false
  }
  
  func connect(_ selectPeripheral: FoundPeripheral,
               options: [String : Any]?) {
    print("# Connect to \(selectPeripheral.name)")
    centralManager.connect(selectPeripheral.peripheral,
                           options: options)
  }
  
  func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
    print("# Cancel Peripheral Connection \(peripheral.name ?? "Unknown")")
    centralManager.cancelPeripheralConnection(peripheral)
  }
  
  func retrievePeripherals(_ identifiers: [UUID]) -> [CBPeripheral] {
    return centralManager.retrievePeripherals(withIdentifiers: identifiers)
  }
  
  func retrieveConnectedPeripherals(_ serviceUUIDs: [CBUUID]) -> [CBPeripheral] {
    return centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs)
  }
  
  func disconnectPeripheral() {
    centralManager.cancelPeripheralConnection(connectedPeripheral)
  }
  
  func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
    connectedPeripheral.setNotifyValue(enabled, for: characteristic)
  }
  
  private func resetConfigure() {
    isSearching = false
    isConnected = false
    
    foundPeripherals = []
    foundServices = []
    foundCharacteristics = []
  }
}

// MARK: - CBCentralManagerDelegate

extension CoreBluetoothManager: CBCentralManagerDelegate {
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print("# centralManagerDidUpdateState \(central.state)")
    if central.state == .poweredOn {
      isBlePower = true
    } else {
      isBlePower = false
    }
  }
  
    func centralManager(_ central: CBCentralManager,
                        willRestoreState dict: [String : Any]) {
      print("# willRestoreState \(dict)")
    }
  
  func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String : Any],
                      rssi RSSI: NSNumber) {
    if RSSI.intValue >= 0 { return }
    var _name = "Unknown device"

    if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
      _name = String(peripheralName)
    } else if let peripheralName = peripheral.name {
      _name = String(peripheralName)
    }
    
    let foundPeripheral: FoundPeripheral = FoundPeripheral(_peripheral: peripheral,
                                                           _name: _name,
                                                           _advData: advertisementData,
                                                           _rssi: RSSI,
                                                           _discoverCount: 0)
    
    if let index = foundPeripherals.firstIndex(where: { $0.peripheral.identifier.uuidString == peripheral.identifier.uuidString }) {
      if foundPeripherals[index].discoverCount % 50 == 0 {
        foundPeripherals[index].name = _name
        foundPeripherals[index].rssi = RSSI.intValue
        foundPeripherals[index].discoverCount += 1
      } else {
        foundPeripherals[index].discoverCount += 1
      }
    } else {
      foundPeripherals.append(foundPeripheral)
      DispatchQueue.main.async { self.isSearching = false }
    }
    
    print("# Found \(_name)")
  }
  
  func centralManager(_ central: CBCentralManager,
                      didConnect peripheral: CBPeripheral) {
    print("# didConnect with \(peripheral.name ?? "Unknown")")
    connectedPeripheral = peripheral
    isConnected = true
    stopScan()
    peripheral.delegate = self
    peripheral.discoverServices(nil)
  }
  
  func centralManager(_ central: CBCentralManager,
                      didFailToConnect peripheral: CBPeripheral,
                      error: Error?) {
    print("# didFailToConnect \(peripheral.name ?? "Unknown")")
  }
  
  func centralManager(_ central: CBCentralManager,
                      didDisconnectPeripheral peripheral: CBPeripheral,
                      error: Error?) {
    resetConfigure()
    print("# didDisconnectPeripheral with \(peripheral.name ?? "Unknown")")
    
    if let error = error {
      print("# didDisconnectPeripheral with \(error.localizedDescription)")
    }
  }
  
  func centralManager(_ central: CBCentralManager,
                      connectionEventDidOccur event: CBConnectionEvent,
                      for peripheral: CBPeripheral) {
    print("# connectionEventDidOccur \(peripheral.name ?? "Unknown")")
  }
  
  func centralManager(_ central: CBCentralManager,
                      didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
    print("# didUpdateANCSAuthorizationFor \(peripheral.name ?? "Unknown")")
  }
}

// MARK: - CBPeripheralDelegate

extension CoreBluetoothManager: CBPeripheralDelegate {
  
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverServices error: Error?) {
    peripheral.services?.forEach { service in
      print("# didDiscoverServices \(service.uuid)")
      let setService: FoundService = FoundService(_uuid: service.uuid, _service: service)
      foundServices.append(setService)
      peripheral.discoverCharacteristics(nil, for: service)
    }
    
    if let error = error {
      print("# didDiscoverServices with \(error.localizedDescription)")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverCharacteristicsFor service: CBService,
                  error: Error?) {
    service.characteristics?.forEach { characteristic in
      print("# didDiscoverCharacteristicsFor \(characteristic.uuid)")
      let setCharacteristic: FoundCharacteristic = FoundCharacteristic(_characteristic: characteristic,
                                                                       _description: "",
                                                                       _uuid: characteristic.uuid,
                                                                       _readValue: "",
                                                                       _service: characteristic.service!)
      foundCharacteristics.append(setCharacteristic)
      
      if characteristic.properties.contains(.read) {
        peripheral.readValue(for: characteristic)
        print("\(characteristic.uuid): properties contains .read")
      }
      if characteristic.properties.contains(.notify) {
        peripheral.setNotifyValue(true, for: characteristic)
        print("\(characteristic.uuid): properties contains .notify")
      }
    }
    
    if let error = error {
      print("# didDiscoverCharacteristics with \(error.localizedDescription)")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didUpdateValueFor characteristic: CBCharacteristic,
                  error: Error?) {
    
    guard let characteristicValue = characteristic.value else { return }
    
    if let index = foundCharacteristics.firstIndex(where: { $0.uuid.uuidString == characteristic.uuid.uuidString }) {
      foundCharacteristics[index].readValue = characteristicValue.map({ String(format:"%02x", $0) }).joined()
    }
    
    // For Demo
    if characteristic.uuid == CBUUID(string: "0x2A37") { // Heart Rate
      notifiedData = "Heart Rate: \(Helper.heartRate(from: characteristic))"
    }
    if characteristic.uuid == CBUUID(string: "2A38") { // Sensor Body Location
      readData = "Body Location: \(Helper.bodyLocation(from: characteristic))"
    }
    
    // let strValue = String(decoding: characteristicValue, as: UTF8.self)
    print("# didUpdateValueFor \(characteristic)")
    
    if let error = error {
      print("# didUpdateValueFor with \(error.localizedDescription)")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didWriteValueFor descriptor: CBDescriptor,
                  error: Error?) {
    
    guard let descriptorValue = descriptor.value else { return }
    print("# didWriteValueFor \(descriptorValue)")
    
    if let error = error {
      print("# didWriteValueFor with \(error.localizedDescription)")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didUpdateNotificationStateFor characteristic: CBCharacteristic,
                  error: Error?) {
    
    print("# didUpdateNotificationStateFor \(characteristic)")
    
    if let error = error {
      print("# didUpdateNotificationStateFor with \(error.localizedDescription)")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didModifyServices invalidatedServices: [CBService]) {
    invalidatedServices.forEach { service in
      print("# didModifyServices \(service.uuid)")
    }
  }
}
