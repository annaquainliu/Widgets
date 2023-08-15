//
//  WidgetViewModel.swift
//  Widgets
//
//  Created by Anna Liu on 7/30/23.
//

import Foundation
import AppKit
import CoreLocation

class WidgetInfo : Codable {
    var type : WidgetInfo.types
    var triggerType : String
    var weather : String?
    var timeFrame : TimeFrameInfo?
    var staticTimeFrame : StaticTimeFrame?
    var xCoord : Double = 0
    var yCoord : Double = 0
    var widgetSize : NSSize
    var imageName : URL
    private var id = UUID()
    
    enum types : Int, Codable {
        case image, calendar, countdown, weather, slideshow
    }
    
    init(triggerType: String, weather: String?, timeFrame: TimeFrameInfo?,
         staticTimeFrame: StaticTimeFrame?, imageName: URL, type: WidgetInfo.types) {
        self.triggerType = triggerType
        self.weather = weather
        self.timeFrame = timeFrame
        self.staticTimeFrame = staticTimeFrame
        self.imageName = imageName
        self.type = type
        self.widgetSize = NSSize()
    }
    
    func initCoordsAndSize(xCoord : Double, yCoord : Double, size : NSSize) {
        self.xCoord = xCoord
        self.yCoord = yCoord
        self.widgetSize = size
    }
    
    func getID() -> UUID {
        return self.id
    }
}

// Stores information of the widget and displays the widget in Edit Mode
class WidgetViewModel : ObservableObject {
    // the displayDesktop class and the WidgetStore is passed in
    init(triggerType: String, timeFrame: TimeFrameInfo?, staticTimeFrame: StaticTimeFrame?,
         weather: String?, store: WidgetStore, displayDesktop: DisplayDesktopWidgets, imageName: URL,
         type: WidgetInfo.types) {
        let widgetInfo = WidgetInfo(triggerType: triggerType,
                                     weather: weather,
                                     timeFrame: timeFrame,
                                     staticTimeFrame: staticTimeFrame,
                                     imageName: imageName,
                                     type: type)
       _ = ScreenWindowController(widget: widgetInfo, displayDesktop: displayDesktop, store: store)
    }
}

class DisplayDesktopWidgets: ObservableObject {
    
    var store : WidgetStore?
    private var currentWidgets : [UUID : ScreenWindowController]
    private var weatherWidgets : [WidgetInfo]
    private var setWeatherInterval = false
    
    init() {
        self.store = nil
        self.currentWidgets = [:]
        self.weatherWidgets = []
    }
    
    func loadWidgets() {
        if store == nil {
            return
        }
        for widget in store!.widgets {
            displayWidget(widget: widget)
        }
    }
    
    func displayWidget(widget: WidgetInfo) {
        switch widget.triggerType {
            case Triggers.always:
                makeWindowController(widget: widget)
            case Triggers.timeFrame:
                displayTimeFrameWidget(widget: widget)
            case Triggers.weather:
                displayWeatherWidget(widget: widget)
            default:
                displayStaticTimeWidget(widget: widget)
        }
    }
    
    @objc private func removeWidgetRepeat(sender: Timer) {
        print("removing widget, now date is: \(Date.now)")
        let widget = (sender.userInfo as? WidgetInfo)!
        removeWidget(id: widget.getID())
        displayWidget(widget: widget) //sets the timer again
    }
    
    @objc private func displayWidgetSelector(sender: Timer) {
        let widget = (sender.userInfo as? WidgetInfo)!
        displayWidget(widget: widget)
    }
    
    private func makeWindowController(widget: WidgetInfo) {
        print("making controller")
        let controller = ScreenWindowController(widget: widget)
        self.currentWidgets[widget.getID()] = controller
    }
    
    // removes widget from storage and from desktop
    private func removeWidget(id: UUID) {
        if self.currentWidgets[id] == nil {
            return
        }
        let controller = self.currentWidgets[id]!
        controller.window?.close()
        self.currentWidgets.removeValue(forKey: id)
    }
    
    @objc private func removeWidgetNoRepeat(sender: Timer) {
        let id = (sender.userInfo as? UUID)!
        removeWidget(id: id)
    }
    
    private func displayStaticTimeWidget(widget: WidgetInfo) {
        let start = widget.staticTimeFrame!.timeStart
        let end = widget.staticTimeFrame!.timeEnd
        let current = Date()
        if (start...end).contains(current) {
            makeWindowController(widget: widget)
            let diffs = Calendar.current.dateComponents([.day], from: current, to: end)
            if diffs.day! <= 5 {
                let timeOut = Timer(fireAt: end,
                                    interval: 0,
                                    target: self,
                                    selector: #selector(removeWidgetNoRepeat(sender:)),
                                    userInfo: widget.getID(),
                                    repeats: false)
                RunLoop.main.add(timeOut, forMode: .common)
            }
        } else if start > current {
            let diffs = Calendar.current.dateComponents([.day], from: current, to: start)
            if diffs.day! <= 5 {
                let timer = Timer(fireAt: start,
                                  interval: 0,
                                  target: self,
                                  selector: #selector(displayWidgetSelector(sender:)),
                                  userInfo: widget,
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .common)
            }
        } else {
            Task {
                await self.store!.deleteWidget(id: widget.getID())
            }
        }
    }
    
    private func displayWeatherWidget(widget: WidgetInfo) {
        if LocationManager.lastKnownLocation == nil {
            _ = alertMessage(question: "Please enable location services to create a weather widget", text: "")
           return
        }
        if !setWeatherInterval {
            setWeatherInterval = true
            let timer = Timer(timeInterval: 1800, repeats: true) { Timer in
                Task {
                    await WeatherManager.fetchWeather()
                    for weatherWidget in self.weatherWidgets {
                        self.displayWeatherHelper(widget: weatherWidget)
                    }
                }
            }
            RunLoop.main.add(timer, forMode: .common)
        }
        Task {
            if WeatherManager.currentConditions == nil {
                await WeatherManager.fetchWeather()
            }
            displayWeatherHelper(widget: widget)
            self.weatherWidgets.insert(widget, at: self.weatherWidgets.endIndex)
        }
    }
    
    private func displayWeatherHelper(widget: WidgetInfo) {
        let isWidgetValid = WeatherManager.shouldWidgetBeOn(widget: widget)
        let widgetIsOn = self.currentWidgets[widget.getID()] != nil
        
        if widgetIsOn != isWidgetValid {
            if widgetIsOn {
                DispatchQueue.main.async {
                    self.removeWidget(id: widget.getID())
                }
            }
            else {
                DispatchQueue.main.async {
                    self.makeWindowController(widget: widget)
                }
            }
        }
    }
    
    private func displayTimeFrameWidget(widget: WidgetInfo) {
        var validTimeFrame = true
//         the time frame must be valid for all widgets
        let timeFrames : [TimeFrameCodable?] = [widget.timeFrame!.date, widget.timeFrame!.Hour, widget.timeFrame!.Month, widget.timeFrame!.Weekday]
        for timeFrame in timeFrames {
            if timeFrame != nil && !timeFrame!.nowWithinTimeRange() {
                validTimeFrame = false
                break
            }
        }
        if validTimeFrame {
            makeWindowController(widget: widget)
            let endingDate = widget.timeFrame!.getEndingTime()
            print("ending date is: \(endingDate)")
            let diffs = Calendar.current.dateComponents([.day], from: Date(), to: endingDate)
            if diffs.day! <= 5 {
                let timer = Timer(fireAt: endingDate,
                                  interval: 0,
                                  target: self,
                                  selector: #selector(removeWidgetRepeat(sender:)),
                                  userInfo: widget,
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .common)
            }
        } else {
            let startingDate = widget.timeFrame!.getStartingTime()
            let diffs = Calendar.current.dateComponents([.day], from: Date(), to: startingDate)
            print("starting date is: \(startingDate)")
            if diffs.day! <= 5 {
                let timer = Timer(fireAt: startingDate,
                                  interval: 0,
                                  target: self,
                                  selector: #selector(displayWidgetSelector(sender:)),
                                  userInfo: widget,
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
}
