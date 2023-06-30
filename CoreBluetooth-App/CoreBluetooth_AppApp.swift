//
//  CoreBluetooth_AppApp.swift
//  CoreBluetooth-App
//
//  Created by Sunil Kumar on 30/01/23.
//

import SwiftUI

@main
struct CoreBluetooth_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(CoreBluetoothManager())
        }
    }
}
