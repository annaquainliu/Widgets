//
//  Library.swift
//  Widgets
//
//  Created by Anna Liu on 8/28/23.
//

import Foundation
import SwiftUI

struct LibraryView : View {
    @State var backButtonPressed = false
    @EnvironmentObject var store : WidgetStore
    @EnvironmentObject var displayDesktopWidgets : DisplayDesktopWidgets
    @State var deleted : [UUID] = []

    
    var body: some View {
        if backButtonPressed {
            ContentView()
        } else {
            VStack(alignment: .leading) {
                WidgetTypeTab(backButtonPressed: $backButtonPressed, titleText: "Library")
                List {
                    ForEach(store.widgets, id: \.self) { widget in
                        if !deleted.contains(widget.getID()) {
                            HStack {
                                // thumbnail of widget in library
                                if FileManager.default.fileExists(atPath: widget.imageURLs[0].relativePath) {
                                    Image(nsImage: NSImage(contentsOf: widget.imageURLs[0])!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                } else {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                }
                                Spacer()
                                Text(widget.trigger.stringifyTrigger()).font(.title2)
                                Spacer()
                                switch widget.info.type {
                                    case WidgetTypeInfo.types.calendar:
                                        Text("Calendar Widget").font(.title2)
                                    case WidgetTypeInfo.types.countdown:
                                        Text("Countdown Widget").font(.title2)
                                    case WidgetTypeInfo.types.image:
                                        Text("Image/Gif Widget").font(.title2)
                                    case WidgetTypeInfo.types.desktop:
                                        Text("Desktop ScreenSaver").font(.title2)
                                    default:
                                        Text("Text Widget").font(.title2)
                                }
                                Spacer()
                                Image(systemName: "trash").font(.system(size: 20))
                                .onTapGesture {
                                    deleted.insert(widget.getID(), at: deleted.count)
                                    self.displayDesktopWidgets.deleteAndRefreshWidget(id: widget.getID())
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }.background(
                AngularGradient(gradient: Gradient(colors: [.purple, .yellow]), center: .topTrailing)
             )
        }
    }
}

struct LibraryView_Providers: PreviewProvider {
    
    static var previews: some View {
        LibraryView()
            .environmentObject(WidgetStore())
    }
}
