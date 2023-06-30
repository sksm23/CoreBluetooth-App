//
//  ContentView.swift
//  CoreBluetooth-App
//
//  Created by Sunil Kumar on 30/01/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      NavigationView {
          ListView()
      }
      .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
