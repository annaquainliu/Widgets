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
    private var widgetInfo : WidgetInfo
    private var windowController : ScreenWindowController
    
    init(triggerType: String, duration: Duration, timeFrame: TimeFrame, weather: String, freq: Frequency, store: WidgetStore) {
        let imageName = "autumn_leaf"
        self.widgetInfo = WidgetInfo(triggerType: triggerType, weather: weather,
                                     duration: duration, timeFrame: timeFrame,
                                     freq: freq, imageName: imageName)
        self.windowController = ScreenWindowController(window: WidgetNSWindow(widgetInfo: widgetInfo, widgetStore: store))
    }
    
    // todo: make verification functions that verify if the inputs are correct
}

class DisplayDesktopWidgets {
    
    static func loadWidgets(store: WidgetStore) {
        for widget in store.widgets {
            displayWidget(widget: widget, store: store)
        }
    }
    
    static func displayWidget(widget: WidgetInfo, store: WidgetStore) {
        switch widget.triggerType {
            case Triggers.always:
            displayAlwaysWidget(widget: widget, store: store)
            default:
                print("default")
        }
    }
    
    @objc func removeWidgetFromDesktop(sender: Timer) {
        let map = sender.userInfo as? [String: Any]
        let controller = map!["controller"] as? ScreenWindowController
        let store = map!["store"] as? WidgetStore
        controller!.window?.close()
        let window = controller!.window as? WidgetNSWindow
        let id = (window?.widgetInfo.getID())!
        Task {
            await store!.deleteWidget(id: id)
        }
    }
    
    // Logic to display widget with trigger "Always"
    // Time frame can be also "Always", other option is within two dates
    static func displayAlwaysWidget(widget: WidgetInfo, store: WidgetStore) {
        if widget.timeFrame.selection == TimeFrame.always ||
            (widget.timeFrame.timeRange[0] ... widget.timeFrame.timeRange[1]).contains(Date()) {
            print("going to display")
            let controller = ScreenWindowController(window: DesktopWidgetWindow(widgetInfo: widget))
            
            if (widget.timeFrame.selection != TimeFrame.always) {
                //delete widget from storage
                _ = Timer(fireAt: Date.now.addingTimeInterval(20),
                      interval: 0,
                      target: self,
                      selector: #selector(removeWidgetFromDesktop(sender:)),
                      userInfo: ["controller": controller, "store": store] as [String : Any],
                      repeats: false)
            }
        }
    }
    
    func displayFrequencyWidget() {
        
    }
}

