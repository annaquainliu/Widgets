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
    var triggerType : String
    var weather : String
    var timeFrame : TimeFrameInfo
    var xCoord : Double = 0
    var yCoord : Double = 0
    var widgetSize : NSSize
    var imageName : String
    private var id = UUID()
    
    init(triggerType: String, weather: String, timeFrame: TimeFrameInfo, imageName: String) {
        self.triggerType = triggerType
        self.weather = weather
        self.timeFrame = timeFrame
        self.imageName = imageName
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

class WidgetViewModel : ObservableObject {
    private var store: WidgetStore
    private var widgetInfo : WidgetInfo
    private var windowController : ScreenWindowController
    private var displayDesktop: DisplayDesktopWidgets
    
    init(triggerType: String, timeFrame: TimeFrameInfo, weather: String, store: WidgetStore,
         displayDesktop: DisplayDesktopWidgets) {
        let imageName = "autumn_leaf"
        self.store = store
        self.displayDesktop = displayDesktop
        self.widgetInfo = WidgetInfo(triggerType: triggerType,
                                     weather: weather,
                                     timeFrame: timeFrame,
                                     imageName: imageName)
        self.windowController = ScreenWindowController(window: WidgetNSWindow(widgetInfo: widgetInfo,
                                                                              widgetStore: store,
                                                                              displayDesktop: displayDesktop))
    }
    
    // todo: make verification functions that verify if the inputs are correct
}

class DisplayDesktopWidgets: ObservableObject {
    
    var store : WidgetStore?
    private var currentWidgets : [UUID : ScreenWindowController]
    
    init() {
        self.store = nil
        self.currentWidgets = [:]
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
        Task {
            await WeatherManager.fetchWeather()
        }
        switch widget.triggerType {
            case Triggers.always:
                makeWindowController(widget: widget)
            case Triggers.timeFrame:
                displayTimeFrameWidget(widget: widget)
            case Triggers.loc:
                displayLocationWidget(widget: widget)
            case Triggers.weather:
                displayWeatherWidget(widget: widget)
            default:
                print("default")
        }
    }
    
    @objc private func removeWidgetSelector(sender: Timer) {
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
        let controller = ScreenWindowController(window: DesktopWidgetWindow(widgetInfo: widget))
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
    
    private func displayLocationWidget(widget: WidgetInfo) {
        if LocationManager.lastKnownLocation == nil {
           print("User denied location")
           return
        }
        
    }
    
    private func displayWeatherWidget(widget: WidgetInfo) {
        if LocationManager.lastKnownLocation == nil {
           print("User denied location")
           return
        }
        Task {
            if WeatherManager.currentConditions == nil {
                await WeatherManager.fetchWeather()
            }
            
            
        }
        /*
            1. see if locations is set - if it isn't, throw error (user denied locations)
            2. if it is, set the widget to be on or off
            4. set a timer for each one
         */
    }
    
    private func displayTimeFrameWidget(widget: WidgetInfo) {
        var validTimeFrame = true
//         the time frame must be valid for all widgets
        let timeFrames : [TimeFrameCodable?] = [widget.timeFrame.date, widget.timeFrame.Hour, widget.timeFrame.Month, widget.timeFrame.Weekday]
        for timeFrame in timeFrames {
            if timeFrame != nil && !timeFrame!.nowWithinTimeRange() {
                validTimeFrame = false
                break
            }
        }
        if validTimeFrame {
            makeWindowController(widget: widget)
            let endingDate = widget.timeFrame.getEndingTime()
            print("ending date is: \(endingDate)")
            let diffs = Calendar.current.dateComponents([.day], from: Date(), to: endingDate)
            if diffs.day! <= 5 {
                let timer = Timer(fireAt: endingDate,
                                  interval: 0,
                                  target: self,
                                  selector: #selector(removeWidgetSelector(sender:)),
                                  userInfo: widget,
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .common)
            }
        } else {
            let startingDate = widget.timeFrame.getStartingTime()
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
