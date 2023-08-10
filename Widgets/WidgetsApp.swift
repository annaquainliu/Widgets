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
    
    var body: some Scene {
        WindowGroup {
            ContentView().task {
                do {
                    try await store.save(newWidgets: []) // COMMENT THIS OUT!
                    try await store.load()
                    displayDesktopWidget.store = store
                    displayDesktopWidget.loadWidgets()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }.environmentObject(store)
             .environmentObject(displayDesktopWidget)
        }
    }
}
