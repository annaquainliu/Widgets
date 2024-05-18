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
        // promise that either returns no widgets or the widgets in the file
        let task = Task<[[String : Any]], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            guard let dailyWidgets = try? JSONSerialization.jsonObject(with: data)
                    as? [[String : Any]] else {
                return []
            }
            return dailyWidgets
        }
        // await the promise, receive the file information
        let jsonObject = try await task.value
        
        // parsing json object
        for obj in jsonObject {
            self.widgets.append(WidgetInfo.decode(obj: obj as! [String : Any]))
        }
    }
    
    
    func save(newWidgets: [WidgetInfo]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(newWidgets)
            let outfile = try Self.fileURL()
            print(outfile)
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
