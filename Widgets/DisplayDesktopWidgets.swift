//
//  DesktopWidgets.swift
//  Widgets
//
//  Created by Anna Liu on 8/2/23.
//

import Foundation
import SwiftUI
//
//  KEEP IN MIND THAT THERE WILL BE DIFFERENT KINDS OF
//  WIDGETS LIKE IMAGE/GIF, SLIDESHOW, CALENDAR
//
class DisplayDesktopWidgets : ObservableObject {
    
    private var store : WidgetStore
    private var controller : ScreenWindowController?
    @Published private var widgets : [WidgetInfo]
    
    init(store : WidgetStore) {
        self.store = store
        self.controller = nil
        self.widgets = store.widgets
    }
    
    func loadWidgets() async {
        let widgets = await store.getWidgets()
        for widget in widgets {
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
        let controller = sender.userInfo as? ScreenWindowController
        controller!.window?.close()
        let window = controller!.window as? WidgetNSWindow
        store.deleteWidget(id: (window?.widgetInfo.getID())!)
    }
    
    // Logic to display widget with trigger "Always"
    // Time frame can be also "Always", other option is within two dates
    func displayAlwaysWidget(widget: WidgetInfo)  {
        if widget.timeFrame.selection == TimeFrame.always ||
            (widget.timeFrame.timeRange[0] ... widget.timeFrame.timeRange[1]).contains(Date()) {
            print("going to display")
            self.controller = ScreenWindowController(window: DesktopWidgetWindow(widgetInfo: widget))
            
            if (widget.timeFrame.selection != TimeFrame.always) {
                //delete widget from storage
                _ = Timer(fireAt: Date.now.addingTimeInterval(20),
                      interval: 0,
                      target: self,
                      selector: #selector(removeWidgetFromDesktop(sender:)),
                      userInfo: controller,
                      repeats: false)
            }
        }
    }
    
    func displayFrequencyWidget() {
        
    }
}
