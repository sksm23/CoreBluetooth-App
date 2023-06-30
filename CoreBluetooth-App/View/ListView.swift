//
//  ListView.swift
//  CoreBluetooth-App
//
//  Created by Sunil Kumar on 30/01/23.
//

import SwiftUI

struct ListView: View {
  
  @EnvironmentObject var bluetoothManager: CoreBluetoothManager
  
  var body: some View {
    ZStack {
      bluetoothManager.navigationToDetailView(isDetailViewLinkActive: $bluetoothManager.isConnected)
      
      GeometryReader { proxy in
        VStack {
          if !bluetoothManager.isSearching {
            Button(action: {
              if bluetoothManager.isSearching {
                bluetoothManager.stopScan()
              } else {
                bluetoothManager.startScan()
              }
            }) {
              bluetoothManager.UIButtonView(proxy: proxy,
                                            text: bluetoothManager.isSearching ? "Stop scan" : "Start scan")
            }
            
            Text(bluetoothManager.isBlePower ? "Bluetooth ON" : "Bluetooth OFF")
              .foregroundColor(bluetoothManager.isBlePower ? .green : .red)
              .padding(10)
            
            List {
              PeripheralCells()
            }
            
          } else {
            //first stack
            Color.gray.opacity(0.6)
              .edgesIgnoringSafeArea(.all)
            ZStack {
              VStack {
                ProgressView()
              }
              VStack {
                Spacer()
                Button(action: {
                  bluetoothManager.stopScan()
                }) {
                  Text("Start scan")
                    .padding()
                }
              }
            }
            .frame(width: proxy.size.width / 2,
                   height: proxy.size.width / 2,
                   alignment: .center)
            .background(Color.gray.opacity(0.5))
          }
        }
      }
    }
    .navigationBarTitle("Devices List")
  }
  
  struct PeripheralCells: View {
    
    @EnvironmentObject var bluetoothManager: CoreBluetoothManager
    
    var body: some View {
      
      ForEach(0 ..< bluetoothManager.foundPeripherals.count, id: \.self) { num in
        Button(action: {
          bluetoothManager.connect(bluetoothManager.foundPeripherals[num],
                                   options: nil)
        }) {
          HStack {
            Text(bluetoothManager.foundPeripherals[num].name)
            Spacer()
            Text("\(bluetoothManager.foundPeripherals[num].rssi) dBm")
          }
        }
      }
    }
  }
}
