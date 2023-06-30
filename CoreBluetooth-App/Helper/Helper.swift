//
//  Helper.swift
//  CoreBluetooth-App
//
//  Created by Sunil Kumar on 15/02/23.
//

import SwiftUI
import CoreBluetooth

struct Helper {
  
  static func heartRate(from characteristic: CBCharacteristic) -> Int {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)
    
    let firstBitValue = byteArray[0] & 0x01
    if firstBitValue == 0 {
      // Heart Rate Value Format is in the 2nd byte
      return Int(byteArray[1])
    } else {
      // Heart Rate Value Format is in the 2nd and 3rd bytes
      return (Int(byteArray[1]) << 8) + Int(byteArray[2])
    }
  }
  
  static func bodyLocation(from characteristic: CBCharacteristic) -> String {
    guard let characteristicData = characteristic.value,
          let byte = characteristicData.first else { return "Error" }
    switch byte {
    case 0: return "Other"
    case 1: return "Chest"
    case 2: return "Wrist"
    case 3: return "Finger"
    case 4: return "Hand"
    case 5: return "Ear Lobe"
    case 6: return "Foot"
    default:
      return "Reserved for future use"
    }
  }
}

//MARK: - Navigation Items

extension CoreBluetoothManager {
  
  func navigationToDetailView(isDetailViewLinkActive: Binding<Bool>) -> some View {
    let navigationToDetailView = NavigationLink("",
                                                destination: DetailView(),
                                                isActive: isDetailViewLinkActive).frame(width: 0, height: 0)
    return navigationToDetailView
  }
}

//MARK: - View Items

extension CoreBluetoothManager {
  
  func UIButtonView(proxy: GeometryProxy, text: String) -> some View {
    let UIButtonView = VStack {
      Text(text)
        .frame(width: proxy.size.width / 1.1,
               height: 50,
               alignment: .center)
        .foregroundColor(Color.blue)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(Color.blue, lineWidth: 2))
    }
    return UIButtonView
  }
}
