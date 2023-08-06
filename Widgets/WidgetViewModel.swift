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
    var timeFrame : TimeFrame
    var xCoord : Double = 0
    var yCoord : Double = 0
    var widgetSize : NSSize
    var imageName : String
    private var id = UUID()
    
    init(triggerType: String, weather: String,timeFrame: TimeFrame, imageName: String) {
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
    
    init(triggerType: String, timeFrame: TimeFrame, weather: String, store: WidgetStore, displayDesktop: DisplayDesktopWidgets) {
        let imageName = "autumn_leaf"
        self.store = store
        self.displayDesktop = displayDesktop
        self.widgetInfo = WidgetInfo(triggerType: triggerType,
                                     weather: weather,
                                     timeFrame: timeFrame,
                                     imageName: imageName)
        print("making widget! id is: \(widgetInfo.getID())")
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
                makeWindowController(widget: widget)
            case Triggers.timeFrame:
                displayTimeFrameWidget(widget: widget)
            default:
                print("default")
        }
    }
    
    @objc private func removeWidgetSelector(sender: Timer) {
        let id = (sender.userInfo as? UUID)!
        removeWidget(id: id)
    }
    
    @objc private func makeWindowControllerSelector(sender: Timer) {
        let widget = (sender.userInfo as? WidgetInfo)!
        makeWindowController(widget: widget)
    }
    
    private func makeWindowController(widget: WidgetInfo) {
        let controller = ScreenWindowController(window: DesktopWidgetWindow(widgetInfo: widget))
        self.currentWidgets[widget.getID()] = controller
    }
    
    // removes widget from storage and from desktop
    private func removeWidget(id: UUID) {
        let controller = self.currentWidgets[id]!
        controller.window?.close()
        Task {
            await store!.deleteWidget(id: id)
        }
        self.currentWidgets.removeValue(forKey: id)
    }
    
    private func displayTimeFrameWidget(widget: WidgetInfo) {
        // the only condition for always trigger widgets is the time frame
        if TimeFrame.timeWithinRange(widget: widget) {
            makeWindowController(widget: widget)
                let timer = Timer(fireAt: widget.timeFrame.timeRange[1],
                                  interval: 0,
                                  target: self,
                                  selector: #selector(removeWidgetSelector(sender:)),
                                  userInfo: widget.getID(),
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .common)
        } else {
            if (Date.now < widget.timeFrame.timeRange[0]) {
                    let timer = Timer(fireAt: widget.timeFrame.timeRange[0],
                                      interval: 0,
                                      target: self,
                                      selector: #selector(makeWindowControllerSelector(sender:)),
                                      userInfo: widget,
                                      repeats: false)
                    RunLoop.main.add(timer, forMode: .common)
            } //if the current date is passed the time range
            else if (Date.now > widget.timeFrame.timeRange[1]) {
                Task {
                    print("widget id: \(widget.getID())")
                    await store!.deleteWidget(id: widget.getID())
                }
            }
        }
    }

}
