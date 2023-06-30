//
//  DetailView.swift
//  CoreBluetooth-App
//
//  Created by Sunil Kumar on 15/02/23.
//

import SwiftUI

struct DetailView: View {
  
  @EnvironmentObject var bluetoothManager: CoreBluetoothManager
  
  var body: some View {
    GeometryReader { proxy in
      VStack {
        Button(action: {
          bluetoothManager.disconnectPeripheral()
          bluetoothManager.stopScan()
        }) {
          bluetoothManager.UIButtonView(proxy: proxy, text: "Cut off")
        }
        
        Text(bluetoothManager.isBlePower ? "Bluetooth ON" : "Bluetooth OFF")
          .foregroundColor(bluetoothManager.isBlePower ? .green : .red)
          .padding(10)
        
        Text(bluetoothManager.readData)
          .foregroundColor(.cyan)
          .font(.system(size: 18, weight: .bold))
          .padding(10)
        
        Text(bluetoothManager.notifiedData)
          .foregroundColor(.pink)
          .font(.system(size: 18, weight: .bold))
          .padding(10)
        
        List {
          CharacteriticCells()
        }
        
        .navigationBarTitle("Device Details")
        .navigationBarBackButtonHidden(true)
      }
    }
  }
  
  struct CharacteriticCells: View {
    
    @EnvironmentObject var bluetoothManager: CoreBluetoothManager
    
    var body: some View {
      ForEach(0 ..< bluetoothManager.foundServices.count, id: \.self) { num in
        
        Section(header: Text("\(bluetoothManager.foundServices[num].uuid)")) {
          
          ForEach(0 ..< bluetoothManager.foundCharacteristics.count, id: \.self) { j in
            
            if bluetoothManager.foundServices[num].uuid == bluetoothManager.foundCharacteristics[j].service.uuid {
              Button(action: {
                //write action
              }) {
                VStack {
                  HStack {
                    Text("uuid: \(bluetoothManager.foundCharacteristics[j].uuid.uuidString)")
                      .font(.system(size: 14))
                      .padding(.bottom, 2)
                    Spacer()
                  }
                  
                  HStack {
                    Text("description: \(bluetoothManager.foundCharacteristics[j].description)")
                      .font(.system(size: 14))
                      .padding(.bottom, 2)
                    Spacer()
                  }
                  HStack {
                    Text("value: \(bluetoothManager.foundCharacteristics[j].readValue)")
                      .font(.system(size: 14))
                      .padding(.bottom, 2)
                    Spacer()
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
