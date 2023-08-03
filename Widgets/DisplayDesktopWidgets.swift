//
//  DesktopWidgets.swift
//  Widgets
//
//  Created by Anna Liu on 8/2/23.
//

import Foundation

//
//  KEEP IN MIND THAT THERE WILL BE DIFFERENT KINDS OF
//  WIDGETS LIKE IMAGE/GIF, SLIDESHOW, CALENDAR
//
class DisplayDesktopWidgets {
    
    private var store = WidgetStore()
    
    init() {
        
    }
    
    func loadWidgets() async {
        do {
            try await store.load()
            let widgets = store.widgets
            for widget in widgets {
                displayWidget(widget: widget)
            }
        } catch {
            fatalError("error in display desktop widgets")
        }
    }
    
    func loadWidget(widget: WidgetInfo) async {
        displayWidget(widget: widget)
    }
    
    func displayWidget(widget: WidgetInfo) {
        switch widget.triggerType {
            case Triggers.always:
                displayAlwaysWidget(widget: widget)
            default:
                print("default")
        }
    }
    
    func displayAlwaysWidget(widget: WidgetInfo)  {
        if widget.timeFrame.selection == TimeFrame.always ||
            (widget.timeFrame.timeRange[0] ... widget.timeFrame.timeRange[1]).contains(Date()) {
            _ = ScreenWindowController(window: DesktopWidgetWindow(widgetInfo: widget))
            
            if (widget.timeFrame.selection != TimeFrame.always) {
//                _ = Timer(fireAt: widget.timeFrame.timeRange[1],
//                      interval: 0,
//                      target: self,
//                      selector: #selector(),
//                      userInfo: widget.getID(),
//                      repeats: false)
            }
        }
    }
    
    func displayFrequencyWidget() {
        
    }
}
