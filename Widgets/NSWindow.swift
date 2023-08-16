//
//  NSWindow.swift
//  Widgets
//
//  Created by Anna Liu on 7/30/23.
//

import Foundation
import AppKit
import Cocoa
import SwiftUI

class WidgetNSWindow : NSWindow {
    
    private var desktopEditMode = false
    private var windowSize : NSSize
    private var store : WidgetStore
    private var displayDesktop : DisplayDesktopWidgets
    var widgetInfo : WidgetInfo
    
    // for widgets that ARE resizable
    init(widgetInfo: WidgetInfo, widgetStore: WidgetStore, displayDesktop: DisplayDesktopWidgets) {
        self.widgetInfo = widgetInfo
        self.store = widgetStore
        self.displayDesktop = displayDesktop
        let image = NSImage(contentsOf: widgetInfo.imageName!)
        self.windowSize = image!.size
        super.init(contentRect: NSRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height),
                   styleMask: [.resizable, .titled, .closable, .fullSizeContentView],
                   backing: NSWindow.BackingStoreType.buffered,
                   defer: true)
        self.contentView = NSImageView(image: image!)
        self.contentView?.addSubview(makeButton())
        adjustWidgetWindow()
    }
    
    // for widgets that are NOT resizable
    init(widgetInfo: WidgetInfo, widgetStore: WidgetStore, displayDesktop: DisplayDesktopWidgets,
         windowSize: NSSize) {
        self.widgetInfo = widgetInfo
        self.store = widgetStore
        self.displayDesktop = displayDesktop
        self.windowSize = windowSize
        super.init(contentRect: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
                   styleMask: [.titled, .closable, .fullSizeContentView],
                   backing: NSWindow.BackingStoreType.buffered,
                   defer: true)
        if widgetInfo.imageName != nil {
            let image = NSImage(contentsOf: widgetInfo.imageName!)!
            let imageView = NSImageView(image: image)
            imageView.imageScaling = .scaleAxesIndependently
            self.contentView = imageView
        }
        adjustWidgetWindow()
    }
    
    
    private func adjustWidgetWindow() {
        self.standardWindowButton(.zoomButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.closeButton)?.isHidden = false
        self.backgroundColor = NSColor.init(calibratedWhite: 1, alpha: 0.3)
        self.maxSize = self.windowSize
        self.aspectRatio = self.windowSize
        self.display()
        self.isMovable = true
        self.isMovableByWindowBackground = true
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.titlebarSeparatorStyle = .none
        self.hasShadow = false
        self.center()
    }
    
    func makeButton() -> NSButton {
        let button = NSButton(frame: NSRect(x: 10, y: 10, width: 20, height: 20))
        button.isBordered = false
        button.wantsLayer = true
        button.layer?.backgroundColor = CGColor.black
        button.layer!.masksToBounds = true
        button.layer!.cornerRadius = 10
        button.image = NSImage(systemSymbolName: "checkmark", accessibilityDescription: "Save Changes")
        button.action = #selector(saveWidget)
        return button
    }
    
    @objc func saveWidget() {
        self.close()
        self.widgetInfo.initCoordsAndSize(xCoord: self.frame.minX,
                                          yCoord: self.frame.minY,
                                          size: NSSize(width: self.frame.width,
                                                       height: self.frame.height))
        Task {
            await store.addWidget(widget: self.widgetInfo)
            displayDesktop.displayWidget(widget: self.widgetInfo)
        }
    }
    
    override public func mouseDown(with event: NSEvent) {
        self.performDrag(with: event)
        if (desktopEditMode) {
            self.backgroundColor = NSColor.init(calibratedWhite: 1, alpha: 0.3)
            self.standardWindowButton(.closeButton)?.isHidden = false
        } else {
            self.backgroundColor = NSColor.clear
            self.standardWindowButton(.closeButton)?.isHidden = true
        }
        desktopEditMode = !desktopEditMode
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.backstopMenu)))
        self.aspectRatio = self.windowSize
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}

class DesktopWidgetWindow : NSWindow {
    
    private var widgetInfo : WidgetInfo
    
    init(widgetInfo: WidgetInfo) {
        self.widgetInfo = widgetInfo
        super.init(contentRect: NSRect(x: widgetInfo.xCoord,
                                       y: widgetInfo.yCoord,
                                       width: widgetInfo.widgetSize.width,
                                       height: widgetInfo.widgetSize.height),
                   styleMask: [.fullSizeContentView],
                   backing: NSWindow.BackingStoreType.buffered,
                   defer: true)
        let effect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: widgetInfo.widgetSize.width,
                                                      height: widgetInfo.widgetSize.height))
        effect.state = .active
        effect.material = .contentBackground
        effect.wantsLayer = true
        effect.layer?.cornerRadius = 15.0
        self.isOpaque = false
        self.contentView = effect
        if widgetInfo.imageName != nil {
            let relativePath = widgetInfo.imageName!.relativePath
            if !FileManager.default.fileExists(atPath: relativePath) {
                _ = alertMessage(question: "\(widgetInfo.imageName!.relativePath) does not exist.", text: "")
                self.close()
                return
            }
            let image = NSImageView(image: NSImage(contentsOfFile: relativePath)!)
            image.frame = NSRect(x: 0, y: 0, width: widgetInfo.widgetSize.width, height: widgetInfo.widgetSize.height)
            image.imageScaling = .scaleAxesIndependently
            self.contentView?.addSubview(image)
        }
        self.backgroundColor = NSColor.clear
        self.aspectRatio = widgetInfo.widgetSize
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.backstopMenu)))
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.hasShadow = false
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}

extension NSWindow {
    
    func makeTimeLayer(defaultWidth: Double, defaultHeight: Double, view: NSHostingView<some View>) {
        view.frame =  NSRect(origin: CGPoint(x: (self.frame.width - defaultWidth) / 2,
                                             y: (self.frame.height - defaultHeight) / 2 + 10),
                             size: CGSize(width: defaultWidth, height: defaultHeight))
        self.contentView?.addSubview(view)
    }
    
    func makeCalendarView(type: CalendarSizes.types) {
        switch type {
            case CalendarSizes.types.calendar:
                self.makeTimeLayer(defaultWidth: CalendarSizes.calWidth,
                                    defaultHeight: CalendarSizes.calHeight,
                                    view: NSHostingView(rootView: CalendarIcon()))
            case CalendarSizes.types.clock:
                self.makeTimeLayer(defaultWidth: CalendarSizes.clockWidth,
                                    defaultHeight: CalendarSizes.clockHeight,
                                    view: NSHostingView(rootView: ClockIcon()))
            default:
            print("default")
        }
        
    }
}

class CalendarWidget: DesktopWidgetWindow {
    
    init(widget: WidgetInfo) {
        super.init(widgetInfo: widget)
        self.makeCalendarView(type: widget.info.calendarType!)
    }
}

class EditCalendarWidget: WidgetNSWindow {
    
    init(widget: WidgetInfo, displayDesktop: DisplayDesktopWidgets, store: WidgetStore) {
        let size = CalendarSizes.makeCalendarSize(type: widget.info.calendarType!)
        super.init(widgetInfo: widget, widgetStore: store,
                   displayDesktop: displayDesktop, windowSize: size)
        self.makeCalendarView(type: widget.info.calendarType!)
        self.contentView?.addSubview(makeButton())
    }
}

class ScreenWindowController : NSWindowController, NSWindowDelegate {
    init(window : NSWindow) {
        super.init(window: window)
        self.window?.makeKeyAndOrderFront(self)
    }
    
    // for edit widget
    init(widget: WidgetInfo, displayDesktop: DisplayDesktopWidgets, store: WidgetStore) {
        var window : NSWindow
        
        switch widget.type {
            case WidgetInfo.types.calendar:
                window = EditCalendarWidget(widget: widget, displayDesktop: displayDesktop, store: store)
                break
            default:
                window = WidgetNSWindow(widgetInfo: widget, widgetStore: store, displayDesktop: displayDesktop)
                break
        }
        super.init(window: window)
        self.window?.makeKeyAndOrderFront(self)
    }
    
    // desktop mode
    init(widget: WidgetInfo) {
        var window: NSWindow
        
        switch widget.type {
            case WidgetInfo.types.calendar:
                window = CalendarWidget(widget: widget)
                break
            default:
                window = DesktopWidgetWindow(widgetInfo: widget)
        }
        super.init(window: window)
        self.window?.makeKeyAndOrderFront(self)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

