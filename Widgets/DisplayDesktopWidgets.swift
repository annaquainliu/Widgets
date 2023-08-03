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
    
    func displayWidget(widget: WidgetInfo) {
        switch widget.triggerType {
            case Triggers.always:
                displayAlwaysWidget(widget: widget)
            default:
                print("sds")
        }
    }
    
    func displayAlwaysWidget(widget: WidgetInfo)  {
        if widget.timeFrame.selection == TimeFrame.always ||
            (widget.timeFrame.timeRange[0] ... widget.timeFrame.timeRange[1]).contains(Date()) {
            
        }
    }
    
    func displayFrequencyWidget() {
        
    }
}
