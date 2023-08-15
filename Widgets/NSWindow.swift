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
    var windowSize : NSSize
    private var store : WidgetStore
    private var displayDesktop : DisplayDesktopWidgets
    var widgetInfo : WidgetInfo
    
    init(widgetInfo: WidgetInfo, widgetStore: WidgetStore, displayDesktop: DisplayDesktopWidgets) {
        self.widgetInfo = widgetInfo
        self.store = widgetStore
        self.displayDesktop = displayDesktop
        let image = NSImage(contentsOf: widgetInfo.imageName)
        self.windowSize = image!.size
        super.init(contentRect: NSRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height),
                   styleMask: [.resizable, .titled, .closable, .fullSizeContentView],
                   backing: NSWindow.BackingStoreType.buffered,
                   defer: true)
        self.contentView = NSImageView(image: image!)
        self.contentView?.addSubview(makeButton())
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
    
    private func makeButton() -> NSButton {
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
                   styleMask: [.fullSizeContentView, .titled],
                   backing: NSWindow.BackingStoreType.buffered,
                   defer: true)
        let relativePath = widgetInfo.imageName.relativePath
        if !FileManager.default.fileExists(atPath: relativePath) {
            _ = alertMessage(question: "\(widgetInfo.imageName.relativePath) does not exist.", text: "")
            self.close()
            return
        }
        self.backgroundColor = NSColor.clear
        self.contentView = NSImageView(image: NSImage(contentsOfFile: relativePath)!)
        self.aspectRatio = widgetInfo.widgetSize
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.backstopMenu)))
        self.standardWindowButton(.zoomButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.hasShadow = false
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}

extension NSWindow {
    func makeCalendarNSView(defaultWidth: Double, defaultHeight: Double) {
        let widthRatio = self.frame.width / defaultWidth
        let heightRatio = self.frame.height / defaultHeight
        let ratio = min(widthRatio, heightRatio)
        let width = defaultWidth * ratio
        let height = defaultHeight * ratio
        print("ratio is \(ratio)")
        let calendarView = NSHostingView(rootView: CalendarView(scale: ratio))
        calendarView.frame = NSRect(origin: CGPoint(x: (self.frame.width - width) / 2,
                                                    y: (self.frame.height - height) / 2),
                                    size: CGSize(width: width, height: height))
        self.contentView?.addSubview(calendarView)
        self.styleMask.remove(.resizable)
    }
}

class CalendarWidget: DesktopWidgetWindow {
    
    init(widget: WidgetInfo) {
        let defaultWidth = 156.5
        let defaultHeight = 168.0
        super.init(widgetInfo: widget)
        self.makeCalendarNSView(defaultWidth: defaultWidth, defaultHeight: defaultHeight)
    }
}

class EditCalendarWidget: WidgetNSWindow {
    
    init(widget: WidgetInfo, displayDesktop: DisplayDesktopWidgets, store: WidgetStore) {
        let defaultWidth = 156.5
        let defaultHeight = 168.0
        super.init(widgetInfo: widget, widgetStore: store, displayDesktop: displayDesktop)
        self.makeCalendarNSView(defaultWidth: defaultWidth, defaultHeight: defaultHeight)
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

