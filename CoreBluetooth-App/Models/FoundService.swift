//
//  FoundService.swift
//  CoreBluetooth-App
//
//  Created by Sunil Kumar on 15/02/23.
//

import CoreBluetooth

class FoundService: Identifiable {
  var id: UUID
  var uuid: CBUUID
  var service: CBService
  
  init(_uuid: CBUUID,
       _service: CBService) {
    
    id = UUID()
    uuid = _uuid
    service = _service
  }
}
