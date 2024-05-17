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
        let task = Task<[WidgetInfo], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let dailyWidgets = JSONSerialization.jsonObject(with: data)
            return dailyWidgets
        }
        // await the promise, receive the file information
        let jsonObject = try await task.value
        
        // parsing json object
        for obj in jsonObject {
            let infoObj = obj["info"]
            let widgetType = WidgetTypeInfo.types(rawValue: infoObj["type"])
            let triggerObj = obj["trigger"]
            let triggerType =  Triggers.types(rawValue: triggerObj["type"])
            
            let info : WidgetTypeInfo;
            if widgetType == WidgetTypeInfo.types.calendar {
                info = CalendarInfo(calendarType: CalendarSizes.types(rawValue: infoObj["calendarType"]))
            }
            else if widgetType == WidgetTypeInfo.types.countdown {
                info = CountDownWidgetInfo(time: infoObj["time"], desc: infoObj["desc"])
            }
            else if widgetType == WidgetTypeInfo.types.desktop {
                info = ScreenWidgetInfo(opacity: infoObj["opacity"])
            }
            else if widgetType == WidgetTypeInfo.types.image {
                info = WidgetTypeInfo(type: WidgetTypeInfo.types.image)
            }
            else {
                info = TextWidgetInfo(text: infoObj["text"], font: infoObj["font"])
            }
            let trigger : Triggers;
            if triggerType == Triggers.types.always {
                trigger = Triggers(type: Triggers.types.always)
            }
            else if triggerType == Triggers.types.staticTimeFrame {
                trigger = StaticTimeFrame(timeStart: triggerObj["timeStart"], timeEnd: triggerObj["timeEnd"])
            }
            else if triggerType == Triggers.types.timeFrame {
                trigger = TimeFrameInfo(Hour: triggerObj["Hour"], Weekday: triggerObj["Weekday"], date: triggerObj["date"], Month: triggerObj["Month"])
            }
            else {
                trigger = WeatherTrigger(weather: WeatherTrigger.types(rawValue: triggerObj["weather"]))
            }
            let urls = obj["imageURLs"]
            let imageURLs = []
            for url in urls {
                imageURLs.append(URL(string: url))
            }
            let widget = WidgetInfo(info: info, trigger: trigger,
                                    imageURLs: imageURLs, slideshow: SlideshowInfo(interval: obj["slideshow"]["interval"]))
            let encodedSize = obj["widgetSize"] as! NSCoder
            widget.initCoordsAndSize(xCoord: obj["xCoord"], yCoord: obj["yCoord"], size: encodedSize.decodeSize())
            self.widgets.append()
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
