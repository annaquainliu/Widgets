//
//  NSWindow.swift
//  Widgets
//
//  Created by Anna Liu on 7/30/23.
//

import Foundation
import AppKit
import SwiftUI
import AVFoundation

extension NSImage {
    func calcMaxRatio(windowSize: NSSize) -> NSSize {
        let widthRatio = windowSize.width / self.size.width
        let heightRatio = windowSize.height / self.size.height
        let ratio = max(widthRatio, heightRatio);
        return NSSize(width: self.size.width * ratio, height: self.size.height * ratio);
    }
}

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
        let image = NSImage(contentsOf: widgetInfo.imageURLs[0])
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
        let bounds = NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height)
        super.init(contentRect: bounds,
                   styleMask: [.titled, .closable, .fullSizeContentView],
                   backing: NSWindow.BackingStoreType.buffered,
                   defer: true)
        if widgetInfo.imageURLs.count > 0 {
            self.contentView = NSView(frame: bounds)
            self.setMediaToFillWindow(url: widgetInfo.imageURLs[0])
        }
        self.adjustWidgetWindow()
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
        let button = NSButton(frame: NSRect(x: 10, y: 10, width: 50, height: 20))
        button.isBordered = false
        button.wantsLayer = true
        button.attributedTitle = NSMutableAttributedString(string: "Save", attributes: [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15)])
        button.layer?.backgroundColor = CGColor.init(red: 0.15, green: 0.8, blue: 0.2, alpha: 1)
        button.layer!.masksToBounds = true
        button.layer!.cornerRadius = 6.5
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
            print("saving widget")
            displayDesktop.displayWidget(widget: self.widgetInfo)
        }
    }
    
    override public func mouseDown(with event: NSEvent) {
        self.performDrag(with: event)
        if (desktopEditMode) {
            self.backgroundColor = NSColor.init(calibratedWhite: 1, alpha: 0.3)
        } else {
            self.backgroundColor = NSColor.clear
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
        let bounds = NSRect(x: widgetInfo.xCoord,
                            y: widgetInfo.yCoord,
                            width: widgetInfo.widgetSize.width,
                            height: widgetInfo.widgetSize.height)
        super.init(contentRect: bounds,
                   styleMask: [.fullSizeContentView],
                   backing: NSWindow.BackingStoreType.buffered,
                   defer: true)
        self.contentView = NSView(frame: bounds)
        let count = widgetInfo.imageURLs.count
        if count == 1 {
            self.setImageBackground(index: 0)
        }
        else if count > 1 {
            let interval = Double(widgetInfo.slideshow!.interval * 60)
            let index = Int.random(in: 0..<count)
            let timer = Timer(timeInterval: interval, repeats: true) { timer in
                let index = Int.random(in: 0..<count)
                self.setImageBackground(index: index)
            }
            self.setImageBackground(index: index)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        }
        self.backgroundColor = NSColor.clear
        self.aspectRatio = widgetInfo.widgetSize
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.backstopMenu)))
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.hasShadow = true
        self.isMovableByWindowBackground = true
    }
    
    func setImageBackground(index: Int) {
        print("set image background, index: \(index)")
        let relativePath = widgetInfo.imageURLs[index].relativePath
        if !FileManager.default.fileExists(atPath: relativePath) {
            _ = alertMessage(question: "\(relativePath) does not exist.", text: "")
            self.close()
            return
        }
        self.setMediaToFillWindow(url: widgetInfo.imageURLs[index])
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override public func mouseDown(with event: NSEvent) {
        self.performDrag(with: event)
    }
}

extension NSWindow {
    
    func setMediaToFillWindow(url: URL) {
        self.contentView?.wantsLayer = true
        self.contentView!.layer = CALayer()
        self.contentView!.layer?.cornerRadius = 14
        self.contentView!.layer?.contentsGravity = .resizeAspectFill
        if url.pathExtension == "gif" {
            self.startGifAnimation(with: url, in: self.contentView!.layer)
        } else {
            self.contentView!.layer?.contents = NSImage(contentsOf: url)
        }
    }
    
    func makeTimeLayer(defaultWidth: Double, defaultHeight: Double, view: NSHostingView<some View>) {
        view.frame = NSRect(origin: CGPoint(x: (self.frame.width - defaultWidth) / 2,
                                            y: (self.frame.height - defaultHeight) / 2),
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
                self.makeTimeLayer(defaultWidth: CalendarSizes.alarmWidth,
                                   defaultHeight: CalendarSizes.alarmHeight,
                                   view: NSHostingView(rootView: AlarmIcon()))
        }
    }
    
    func startGifAnimation(with url: URL?, in layer: CALayer?) {
        let animation: CAKeyframeAnimation? = animationForGif(with: url)
        if let animation = animation {
            layer?.add(animation, forKey: "contents")
        }
    }
        
    func animationForGif(with url: URL?) -> CAKeyframeAnimation? {

        let animation = CAKeyframeAnimation(keyPath: "contents")

        var frames = [CGImage]()
        var delayTimes = [NSNumber]()

        var totalTime: Float = 0.0
    //        var gifWidth: Float
    //        var gifHeight: Float
        let gifSource = CGImageSourceCreateWithURL(url! as CFURL, nil)
        // get frame count
        let frameCount = CGImageSourceGetCount(gifSource!)
        for i in 0..<frameCount {
            // get each frame
            let frame = CGImageSourceCreateImageAtIndex(gifSource!, i, nil)
            if let frame = frame {
                frames.append(frame)
            }
            // get gif info with each frame
            let dict = CGImageSourceCopyPropertiesAtIndex(gifSource!, i, nil) as? [CFString: AnyObject]
            let gifDict = dict?[kCGImagePropertyGIFDictionary]
            if let value = gifDict?[kCGImagePropertyGIFDelayTime] as? NSNumber {
                delayTimes.append(value)
            }
            totalTime = totalTime + (((gifDict?[kCGImagePropertyGIFDelayTime] as? NSNumber)?.floatValue)!)

        }

        var times = [AnyHashable](repeating: 0, count: 3)
        var currentTime: Float = 0
        let count: Int = delayTimes.count
        for i in 0..<count {
            times.append(NSNumber(value: Float((currentTime / totalTime))))
            currentTime += Float(truncating: delayTimes[i])
        }

        var images = [AnyHashable](repeating: 0, count: 3)
        for i in 0..<count {
            images.append(frames[i])
        }

        animation.keyTimes = times as? [NSNumber]
        animation.values = images
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = CFTimeInterval(totalTime)
        animation.repeatCount = Float.infinity

        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.isRemovedOnCompletion = false

        return animation

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
        let amnt = self.contentView!.subviews.count
        self.contentView?.subviews[amnt - 1].frame.origin.y += 10
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
                break;
            default:
                window = WidgetNSWindow(widgetInfo: widget, widgetStore: store, displayDesktop: displayDesktop)
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
