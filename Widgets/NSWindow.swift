//
//  NSWindow.swift
//  Widgets
//
//  Created by Anna Liu on 7/30/23.
//
import AVFoundation
import Foundation
import AppKit
import SwiftUI

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
    var windowSize : NSSize
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
        self.contentView?.addSubview(WidgetNSWindow.makeButton())
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
            self.setMediaToFillWindow(url: widgetInfo.imageURLs[0], radius: 13)
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
    
    static func makeButton() -> NSButton {
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
        var index = 0
        if count > 1 {
            let interval = Double(widgetInfo.slideshow.interval * 60)
            let timer = Timer(timeInterval: interval, repeats: true) { timer in
                index = (index + 1) % count
                self.setImageBackground(index: index)
            }
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        }
        self.setImageBackground(index: index)
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
            NSException(name:NSExceptionName(rawValue: "FileNotFound"), reason:"File does not exist", userInfo:nil).raise()
            return
        }
        let cornerRadius = widgetInfo.info.type == WidgetTypeInfo.types.desktop ? 0 : 13
        self.setMediaToFillWindow(url: widgetInfo.imageURLs[index], radius: cornerRadius)
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override public func mouseDown(with event: NSEvent) {
        self.performDrag(with: event)
    }
}

extension String {
    
   func sizeOfString(usingFont font: NSFont) -> NSSize  {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size
    }
}

extension NSText {
    func resizeFrame(windowSize: NSSize) {
        self.frame = NSRect(x: 0, y: (windowSize.height - self.fittingSize.height) / 2,
                            width: windowSize.width, height: self.fittingSize.height)
    }
}

extension NSWindow {
    
    func makeTextView(widget: WidgetInfo) {
        let textinfo = widget.info as! TextWidgetInfo
        let textView = NSHostingView(rootView: TextLayerView(size: self.frame.size, info: textinfo))
        let size = textView.fittingSize
        textView.frame = NSRect(x: (self.frame.width - size.width) / 2,
                                y: (self.frame.height - size.height) / 2,
                                width: size.width, height: size.height)
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.autoresizesSubviews = true
        textView.autoresizingMask = [NSView.AutoresizingMask.minXMargin,
                                    NSView.AutoresizingMask.minYMargin,
                                     NSView.AutoresizingMask.maxXMargin,
                                     NSView.AutoresizingMask.maxYMargin]
        self.contentView?.addSubview(textView)
    }
    
    func setMediaToFillWindow(url: URL, radius: Int) {
        self.contentView?.wantsLayer = true
        self.contentView!.layer = CALayer()
        self.contentView!.layer?.cornerRadius = CGFloat(radius)
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
    
    func startGifAnimation(with url: URL, in layer: CALayer?) {
        print("starting animation")
        let animation: CAKeyframeAnimation? = animationForGif(with: url)
        if let animation = animation {
            layer?.add(animation, forKey: "contents")
        }
    }
    
        
    func animationForGif(with url: URL) -> CAKeyframeAnimation? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(src)

        // Total loop time
        var time : Float = 0

        // Arrays
        var framesArray = [AnyObject]()
        var tempTimesArray = [NSNumber]()

        // Loop
        for i in 0..<frameCount {

            // Frame default duration
            var frameDuration : Float = 0.1;

            let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, i, nil)
            guard let framePrpoerties = cfFrameProperties as? [String:AnyObject] else {return nil}
            guard let gifProperties = framePrpoerties[kCGImagePropertyGIFDictionary as String] as? [String:AnyObject]
                else { return nil }

            // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
            if let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
                frameDuration = delayTimeUnclampedProp.floatValue
            } else {
                if let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                    frameDuration = delayTimeProp.floatValue
                }
            }

            // Make sure its not too small
            if frameDuration < 0.011 {
                frameDuration = 0.100;
            }

            // Add frame to array of frames
            if let frame = CGImageSourceCreateImageAtIndex(src, i, nil) {
                tempTimesArray.append(NSNumber(value: frameDuration))
                framesArray.append(frame)
            }

            // Compile total loop time
            time = time + frameDuration
        }

        var timesArray = [NSNumber]()
        var base : Float = 0
        for duration in tempTimesArray {
            timesArray.append(NSNumber(value: base))
            base += ( duration.floatValue / time )
        }
        // From documentation of 'CAKeyframeAnimation':
        // the first value in the array must be 0.0 and the last value must be 1.0.
        // The array should have one more entry than appears in the values array.
        // For example, if there are two values, there should be three key times.
        timesArray.append(NSNumber(value: 1.0))

        // Create animation
        let animation = CAKeyframeAnimation(keyPath: "contents")

        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.duration = CFTimeInterval(time)
        animation.repeatCount = Float.greatestFiniteMagnitude;
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.values = framesArray
        animation.keyTimes = timesArray
        //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.calculationMode = CAAnimationCalculationMode.discrete

        return animation;
    }

}

class CalendarWidget: DesktopWidgetWindow {
    
    init(widget: WidgetInfo) {
        super.init(widgetInfo: widget)
        let calendar = widget.info as! CalendarInfo
        self.makeCalendarView(type: calendar.calendarType)
    }
}

class EditCalendarWidget: WidgetNSWindow {
    
    init(widget: WidgetInfo, displayDesktop: DisplayDesktopWidgets, store: WidgetStore) {
        let calendar = widget.info as! CalendarInfo
        let size = CalendarSizes.makeCalendarSize(type: calendar.calendarType)
        super.init(widgetInfo: widget, widgetStore: store,
                   displayDesktop: displayDesktop, windowSize: size)
        self.makeCalendarView(type: calendar.calendarType)
        let amnt = self.contentView!.subviews.count
        self.contentView?.subviews[amnt - 1].frame.origin.y += 10
        self.contentView?.addSubview(WidgetNSWindow.makeButton())
    }
}

class ScreenSaverWidget: DesktopWidgetWindow {
    
    init(widget: WidgetInfo) {
        super.init(widgetInfo: widget)
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        self.ignoresMouseEvents = true
        let desktop = widget.info as! ScreenWidgetInfo
        self.contentView!.layer?.opacity = desktop.opacity
    }

}

class EditScreenWidget {
    init(widget: WidgetInfo, displayDesktop: DisplayDesktopWidgets, store: WidgetStore) {
        var size = NSScreen.main?.frame.size ?? NSSize(width: 1200, height: 700)
        size.height -= NSMenu().menuBarHeight
        widget.initCoordsAndSize(xCoord: 0, yCoord: 0, size: size)
        Task {
            await store.addWidget(widget: widget)
        }
        displayDesktop.displayWidget(widget: widget)
    }

}

class EditCountdownWidget : WidgetNSWindow {
    
    init(widget: WidgetInfo, displayDesktop: DisplayDesktopWidgets, store: WidgetStore) {
        super.init(widgetInfo: widget, widgetStore: store,
                   displayDesktop: displayDesktop,
                   windowSize: NSSize(width: Countdown.width, height: Countdown.height))
        let countdown = widget.info as! CountDownWidgetInfo
        let view = NSHostingView(rootView: Countdown(end: countdown.time, desc: countdown.desc))
        view.frame = NSRect(x: 0, y: 0, width: Countdown.width, height: Countdown.height)
        self.contentView?.addSubview(view)
        self.contentView?.addSubview(WidgetNSWindow.makeButton())
    }
}

class CountdownWidget: DesktopWidgetWindow {
    
    init(widget: WidgetInfo) {
        super.init(widgetInfo: widget)
        let countdown = widget.info as! CountDownWidgetInfo
        let view = NSHostingView(rootView: Countdown(end: countdown.time, desc: countdown.desc))
        view.frame = NSRect(x: 0, y: 0, width: Countdown.width, height: Countdown.height)
        self.contentView?.addSubview(view)
    }
}

class EditTextWidget: WidgetNSWindow {
    init(widget: WidgetInfo, displayDesktop: DisplayDesktopWidgets, store: WidgetStore) {
        super.init(widgetInfo: widget, widgetStore: store, displayDesktop: displayDesktop)
        self.makeTextView(widget: widget)
    }
}

class TextWidget: DesktopWidgetWindow {
    
    init(widget: WidgetInfo) {
        super.init(widgetInfo: widget)
        self.makeTextView(widget: widget)
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
        
        switch widget.info.type {
            case WidgetTypeInfo.types.calendar:
                window = EditCalendarWidget(widget: widget, displayDesktop: displayDesktop, store: store)
                break;
            case WidgetTypeInfo.types.desktop:
                _ = EditScreenWidget(widget: widget, displayDesktop: displayDesktop, store: store)
                window = NSWindow()
                super.init(window: window)
                self.window?.close()
                return
            case WidgetTypeInfo.types.countdown:
                window = EditCountdownWidget(widget: widget, displayDesktop: displayDesktop, store: store)
                break;
            case WidgetTypeInfo.types.text:
                window = EditTextWidget(widget: widget, displayDesktop: displayDesktop, store: store)
                super.init(window: window)
                self.window?.makeKeyAndOrderFront(self)
                self.window?.delegate = self
                return
            default:
                window = WidgetNSWindow(widgetInfo: widget, widgetStore: store, displayDesktop: displayDesktop)
        }
        super.init(window: window)
        self.window?.makeKeyAndOrderFront(self)
    }
    
    // desktop mode
    init(widget: WidgetInfo) {
        var window: NSWindow
        
        switch widget.info.type {
            case WidgetTypeInfo.types.calendar:
                window = CalendarWidget(widget: widget)
                break
            case WidgetTypeInfo.types.desktop:
                window = ScreenSaverWidget(widget: widget)
                break;
            case WidgetTypeInfo.types.countdown:
                window = CountdownWidget(widget: widget)
                break;
            case WidgetTypeInfo.types.text:
                window = TextWidget(widget: widget)
                break;
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
