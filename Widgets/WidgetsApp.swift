//
//  WidgetsApp.swift
//  Widgets
//
//  Created by Anna Liu on 7/26/23.
//

import SwiftUI

@main
struct WidgetsApp: App {
    
    @StateObject private var store = WidgetStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store).task {
                DisplayDesktopWidgets.loadWidgets(store: store)
                do {
                    try await store.load()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
