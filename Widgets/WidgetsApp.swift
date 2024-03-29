//
//  WidgetsApp.swift
//  Widgets
//
//  Created by Anna Liu on 7/26/23.
//

import SwiftUI

@main
struct WidgetsApp: App {
    
    @StateObject var store = WidgetStore()
    @StateObject var displayDesktopWidget = DisplayDesktopWidgets()
    var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView().task {
                NSApp.setActivationPolicy(.accessory)
                do {
                    try await store.load()
                    displayDesktopWidget.store = store
                    locationManager.displayDesktopWidgets = displayDesktopWidget
                    locationManager.startUpdating()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }.environmentObject(store)
             .environmentObject(displayDesktopWidget)
        }
        MenuBarExtra("App", systemImage: "app.gift.fill") {
            Button {
                exit(0)
            } label: {
                Text("Close App")
            }
        }
    }
}
