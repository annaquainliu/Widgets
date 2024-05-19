//
//  WidgetStore.swift
//  Widgets
//
//  Created by Anna Liu on 8/1/23.
//

import Foundation

class WidgetStore: ObservableObject {
    var widgets: [WidgetInfo] = []
    
    // file url that saves the information of widgets
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
            guard let dailyWidgets = try? JSONDecoder().decode([WidgetInfo].self, from: data) else {
                return []
            }
            return dailyWidgets
        }
        self.widgets = try await task.value
    }
    
    /*
            save : [WidgetInfo] -> ()
            
            Takes in an array of widgets and REPLACES the json file with
            the array of widgets
     */
    func save(newWidgets: [WidgetInfo]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(newWidgets)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
        self.widgets = newWidgets
    }
    
    func deleteWidget(id : UUID) async {
        var newWidgets : [WidgetInfo] = []
        for widget in self.widgets {
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
