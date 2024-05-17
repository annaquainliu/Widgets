//
//  WidgetViewModel.swift
//  Widgets
//
//  Created by Anna Liu on 7/30/23.
//

import Foundation
import AppKit
import CoreLocation

class DisplayDesktopWidgets: ObservableObject {
    
    var store : WidgetStore?
    private var currentWidgets : [UUID : ScreenWindowController]
    private var weatherWidgets : [WidgetInfo]
    private var setWeatherInterval = false
    private var loaded = false
    
    init() {
        self.store = nil
        self.currentWidgets = [:]
        self.weatherWidgets = []
    }
    
    // CAN ONLY BE CALLED ONCE!
    func loadWidgets() {
        if store == nil || self.loaded {
            return
        }
        print("loading widgets!!")
        for widget in store!.widgets {
            displayWidget(widget: widget)
        }
        self.loaded = true
    }
    
    func displayWidget(widget: WidgetInfo) {
        switch widget.trigger.type {
            case Triggers.types.always:
                print("always")
                makeWindowController(widget: widget)
                break
            case Triggers.types.timeFrame:
                displayTimeFrameWidget(widget: widget)
                break
            case Triggers.types.weather:
                displayWeatherWidget(widget: widget)
                break
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
        let controller : ScreenWindowController;
        do {
            controller = ScreenWindowController(widget: widget)
        }
        catch let error {
            return;
        }
        self.currentWidgets[widget.getID()] = controller
    }
    
    // removes widget view from desktop, it does not delete from storage
    private func removeWidget(id: UUID) {
        if self.currentWidgets[id] == nil {
            return
        }
        let controller = self.currentWidgets[id]!
        controller.window?.close()
        self.currentWidgets.removeValue(forKey: id)
    }
    
    // deletes widget from storage and from desktop view
    public func deleteAndRefreshWidget(id: UUID) {
        removeWidget(id: id)
        Task {
            await store?.deleteWidget(id: id)
        }
    }
    
    @objc private func removeWidgetNoRepeat(sender: Timer) {
        let id = (sender.userInfo as? UUID)!
        removeWidget(id: id)
    }
    
    private func displayStaticTimeWidget(widget: WidgetInfo) {
        let trigger = widget.trigger as StaticTimeFrame
        let start = trigger.timeStart
        let end = trigger.timeEnd
        let current = Date()
        let diffs = Calendar.current.dateComponents([.day], from: current, to: end)
        if diffs.day! <= 5 {
            if (start...end).contains(current) {
                makeWindowController(widget: widget)
                let timeOut = Timer(fireAt: end,
                                    interval: 0,
                                    target: self,
                                    selector: #selector(removeWidgetNoRepeat(sender:)),
                                    userInfo: widget.getID(),
                                    repeats: false)
                RunLoop.main.add(timeOut, forMode: .common)
            } else if start > current {
                let timer = Timer(fireAt: start,
                                  interval: 0,
                                  target: self,
                                  selector: #selector(displayWidgetSelector(sender:)),
                                  userInfo: widget,
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .common)
            } else {
                Task {
                    await self.store!.deleteWidget(id: widget.getID())
                }
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
            print("setting timer")
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
        let trigger = widget.trigger as TimeFrameInfo
        let timeFrames : [TimeFrameCodable?] = [trigger.date, trigger.Hour, trigger.Month, trigger.Weekday]
        for timeFrame in timeFrames {
            if timeFrame != nil && !timeFrame!.nowWithinTimeRange() {
                validTimeFrame = false
                break
            }
        }
        if validTimeFrame {
            print(widget.timeFrame!, " is valid!")
            makeWindowController(widget: widget)
            let endingDate = widget.timeFrame!.getEndingTime()
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
            print(widget.timeFrame!.Hour as Any, " is not valid!")
            let startingDate = widget.timeFrame!.getStartingTime()
            let diffs = Calendar.current.dateComponents([.day], from: Date(), to: startingDate)
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
