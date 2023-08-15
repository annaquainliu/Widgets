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
//                do {
//                    print("starting app")
//                    try await store.save(newWidgets: [])
//                    try await store.load()
//                    displayDesktopWidget.store = store
//                    locationManager.displayDesktopWidgets = displayDesktopWidget
//                    locationManager.startUpdating()
//                } catch {
//                    fatalError(error.localizedDescription)
//                }
                _ = ScreenWindowController(widget: WidgetInfo(triggerType: Triggers.always,
                                                              weather: nil,
                                                              timeFrame: nil,
                                                              staticTimeFrame: nil,
                                                              imageName: URL(filePath: "/Users/annaliu/Downloads/ghost.png"),
                                                              type: WidgetInfo.types.calendar),
                                           displayDesktop: displayDesktopWidget,
                                           store: store)
            }.environmentObject(store)
             .environmentObject(displayDesktopWidget)
        }
    }
}
