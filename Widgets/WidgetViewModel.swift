//
//  WidgetViewModel.swift
//  Widgets
//
//  Created by Anna Liu on 7/30/23.
//

import Foundation
import AppKit

class WidgetInfo : Codable {
    private var triggerType : String
    private var weather : String
    private var duration : Duration
    private var timeFrame : TimeFrame
    private var freq : Frequency
    private var xCoord : Double = 0
    private var yCoord : Double = 0
    private var widgetSize : NSSize
    private var imageName : String
    
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
    
    init(triggerType : String, duration : Duration, timeFrame : TimeFrame, weather : String, freq : Frequency) async {
        let imageName = "autumn_leaf"
        self.widgetInfo = WidgetInfo(triggerType: triggerType, weather: weather, duration: duration, timeFrame: timeFrame, freq: freq, imageName: imageName)
        self.windowController = await ScreenWindowController(image_name: imageName, widgetInfo: widgetInfo)
    }
    
//    private func InitializeWidgetBasedOnTrigger() {
//        switch self.triggerType {
//            case Triggers.freq:
//                frequencyTrigger()
//            default:
//                print("poo")
//        }
//    }
//
//    private func frequencyTrigger() {
//        Timer(fireAt: freq.startDate,
//              interval: 0,
//              target: self,
//              selector: #selector(),
//              userInfo: nil,
//              repeats: false)
//    }
    // todo: make verification functions
}
