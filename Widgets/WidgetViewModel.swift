//
//  WidgetViewModel.swift
//  Widgets
//
//  Created by Anna Liu on 7/30/23.
//

import Foundation
import AppKit

class WidgetInfo : Codable {
    var triggerType : String
    var weather : String
    var duration : Duration
    var timeFrame : TimeFrame
    var freq : Frequency
    var xCoord : Double = 0
    var yCoord : Double = 0
    var widgetSize : NSSize
    var imageName : String
    private var id = UUID()
    
    init(triggerType: String, weather: String, duration: Duration, timeFrame: TimeFrame, freq: Frequency, imageName: String) {
        self.triggerType = triggerType
        self.weather = weather
        self.duration = duration
        self.timeFrame = timeFrame
        self.freq = freq
        self.imageName = imageName
        self.widgetSize = NSSize()
    }
    
    func printSelf() {
        print("trigger type: \(triggerType), weather: \(weather), duration: \(duration), timeFrame: \(timeFrame), freq: \(freq)")
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
    
    init(triggerType: String, duration: Duration, timeFrame: TimeFrame, weather: String, freq: Frequency, store: WidgetStore, displayDesktop: DisplayDesktopWidgets) {
        let imageName = "autumn_leaf"
        self.store = store
        self.displayDesktop = displayDesktop
        self.widgetInfo = WidgetInfo(triggerType: triggerType, weather: weather,
                                     duration: duration, timeFrame: timeFrame,
                                     freq: freq, imageName: imageName)
        self.windowController = ScreenWindowController(window: WidgetNSWindow(widgetInfo: widgetInfo, widgetStore: store, displayDesktop: displayDesktop))
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
        for widget in store!.widgets {
            displayWidget(widget: widget)
        }
    }
    
    func displayWidget(widget: WidgetInfo) {
        switch widget.triggerType {
            case Triggers.always:
            displayAlwaysWidget(widget: widget)
            default:
                print("default")
        }
    }
    
    @objc func removeWidgetFromDesktop(sender: Timer) {
        let id = sender.userInfo as? UUID
        let controller = self.currentWidgets[id!]!
        controller.window?.close()
        Task {
            await store!.deleteWidget(id: id!)
        }
        self.currentWidgets.removeValue(forKey: id!)
    }
    
    // Logic to display widget with trigger "Always"
    // Time frame can be also "Always", other option is within two dates
    func displayAlwaysWidget(widget: WidgetInfo) {
        if widget.timeFrame.selection == TimeFrame.always ||
            (widget.timeFrame.timeRange[0] ... widget.timeFrame.timeRange[1]).contains(Date()) {
            let controller = ScreenWindowController(window: DesktopWidgetWindow(widgetInfo: widget))
            self.currentWidgets[widget.getID()] = controller
            if (widget.timeFrame.selection != TimeFrame.always) {
                let timer = Timer(fireAt: widget.timeFrame.timeRange[1],
                                  interval: 0,
                                  target: self,
                                  selector: #selector(removeWidgetFromDesktop(sender:)),
                                  userInfo: widget.getID(),
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    func displayFrequencyWidget() {
        
    }
}
