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
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) var controlActiveState
    
    var body: some Scene {
        WindowGroup(id: "main") {
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
            Button {
                let windows = NSApplication.shared.windows
                for window in windows {
                    if let id = window.identifier {
                        if id.rawValue == "main-AppWindow-1" {
                            return;
                        }
                    }
                }
                openWindow(id: "main")
            } label: {
                Text("Open App")
            }
        }
        
    }
}
