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
import Quartz

extension NSImage {
    func resizedMaintainingAspectRatio(screenWidth: CGFloat, screenHeight: CGFloat) -> NSImage {
        var ratioX = screenWidth / size.width
        var ratioY = screenHeight / size.height
        if (ratioX > 1 || ratioY > 1) {
            ratioX = size.width / screenWidth
            ratioY = size.height / screenHeight
        }
        let ratio = ratioX < ratioY ? ratioX : ratioY
        let newHeight = size.height * ratio
        let newWidth = size.width * ratio
        let newSize = NSSize(width: newWidth, height: newHeight)
        let image = NSImage(size: NSSize(width: newWidth, height: newHeight))
        image.lockFocus()
        let context = NSGraphicsContext.current
        context!.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: newSize), from: NSZeroRect, operation: .copy, fraction: 1)
        image.unlockFocus()
        return image
    }
}


class WidgetNSWindow : NSWindow {
    
    private var desktopEditMode = false
    private var imageSize : NSSize
    private var store : WidgetStore
    private var displayDesktop : DisplayDesktopWidgets
    var widgetInfo : WidgetInfo
    
    init(widgetInfo: WidgetInfo, widgetStore: WidgetStore, displayDesktop: DisplayDesktopWidgets) {
        self.widgetInfo = widgetInfo
        self.store = widgetStore
        self.displayDesktop = displayDesktop
        let image = NSImage(contentsOf: widgetInfo.imageName)
        self.imageSize = image!.size
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
        self.maxSize = self.imageSize
        self.aspectRatio = self.imageSize
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
        self.aspectRatio = self.imageSize
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
        self.backgroundColor = NSColor.clear
        let relativePath = widgetInfo.imageName.relativePath
        if !FileManager.default.fileExists(atPath: relativePath) {
            _ = alertMessage(question: "\(widgetInfo.imageName.relativePath) does not exist.", text: "")
            self.close()
            return
        }
        print(relativePath)
        self.contentView = NSImageView(image: NSImage(contentsOfFile: relativePath)!)
        self.aspectRatio = widgetInfo.widgetSize
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}

class ScreenWindowController : NSWindowController, NSWindowDelegate {
    init(window : NSWindow) {
        super.init(window: window)
        self.window?.makeKeyAndOrderFront(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

