//
//  WidgetStore.swift
//  Widgets
//
//  Created by Anna Liu on 8/1/23.
//

import Foundation

class WidgetStore: ObservableObject {
    var widgets: [WidgetInfo] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("widgets.data")
    }
    
    func load() async throws {
        let task = Task<[WidgetInfo], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let dailyWidgets = try JSONDecoder().decode([WidgetInfo].self, from: data)
            return dailyWidgets
        }
        let widgets = try await task.value
        self.widgets = widgets
    }
    
    func save(newWidgets: [WidgetInfo]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(newWidgets)
            let outfile = try Self.fileURL()
            print(outfile)
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    func deleteWidget(id : UUID) async {
        var newWidgets : [WidgetInfo] = []
        for widget in widgets {
            if widget.getID() != id {
                newWidgets.append(widget)
            }
        }
        self.widgets = newWidgets
        do {
            try await self.save(newWidgets: self.widgets)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func addWidget(widget : WidgetInfo) async {
        do {
            self.widgets.append(widget)
            try await self.save(newWidgets: self.widgets)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}
