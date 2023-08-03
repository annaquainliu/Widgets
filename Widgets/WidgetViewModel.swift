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
    
    init(triggerType: String, weather: String, duration: Duration, timeFrame: TimeFrame, freq: Frequency, imageName : String) {
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
}

class WidgetViewModel : ObservableObject {
    private var widgetInfo : WidgetInfo
    private var windowController : ScreenWindowController
    
    init(triggerType : String, duration : Duration, timeFrame : TimeFrame, weather : String, freq : Frequency) {
        let imageName = "autumn_leaf"
        self.widgetInfo = WidgetInfo(triggerType: triggerType, weather: weather, duration: duration, timeFrame: timeFrame, freq: freq, imageName: imageName)
        self.windowController = ScreenWindowController(window: WidgetNSWindow(widgetInfo: widgetInfo))
    }
    
    // todo: make verification functions that verify if the inputs are correct
}
