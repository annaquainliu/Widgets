//
//  ImageOrGifView.swift
//  Widgets
//
//  Created by Anna Liu on 7/27/23.
//

import Foundation
import SwiftUI

func ImageOrGifView() -> SuperView {
    return SuperView(title: "Image or Gif", type: WidgetInfo.types.image)
}

func ScreenSaverView() -> SuperView {
    return SuperView(title: "Desktop Background", type: WidgetInfo.types.desktop)
}

struct SuperView: View {
    @EnvironmentObject var store : WidgetStore
    @State var fileName : [URL] = []
    @State var backButtonPressed = false
    @State var info = WidgetTypeInfo()
    var title : String
    var type : WidgetInfo.types
    
    var body : some View {
        if backButtonPressed {
            ContentView()
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    WidgetTypeTab(backButtonPressed: $backButtonPressed, titleText: title)
                    Spacer().frame(height: 30)
                    HStack {
                        FilePicker(files: $fileName)
                        Spacer(minLength: 40)
                        WidgetMenu(type: type, info: $info, fileNames: $fileName)
                    }.padding()
                }.padding()
                 .frame(width: 1200)
            }.frame(height: 700)
        }
    }
}
struct CalendarView : View {
    
    @EnvironmentObject var store : WidgetStore
    @State var fileName : [URL] = []
    @State var selection : Date = Date()
    @State var backButtonPressed : Bool = false
    @State var info = WidgetTypeInfo(calendarType: CalendarSizes.types.calendar)
    let width : CGFloat = 1100
    let height : CGFloat = 700
    
    var body: some View {
        if backButtonPressed {
            ContentView()
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    WidgetTypeTab(backButtonPressed: $backButtonPressed, titleText: "Calendar")
                    HStack {
                        VStack(alignment: .center) {
                            Text("Choose Your Type").font(.title)
                            HStack {
                                makeCalendarButton(view: Image(systemName: "calendar").font(.system(size: 90)), type: CalendarSizes.types.calendar)
                               makeCalendarButton(view: Image(systemName: "clock.fill").font(.system(size: 90)), type: CalendarSizes.types.clock)
                                makeCalendarButton(view: Image(systemName: "textformat").font(.system(size: 90)), type: CalendarSizes.types.text)
                            }
                        }
                    }.frame(width: width)
                    Spacer().frame(height: 30)
                    HStack {
                        FilePicker(files: $fileName)
                        WidgetMenu(type: WidgetInfo.types.calendar, info: $info, fileNames: $fileName)
                    }.padding()
                }.padding()
            }.frame(width: width, height: height)
        }
    }
    
    func makeCalendarButton(view: some View, type: CalendarSizes.types) -> some View {
        return view
            .labelsHidden()
            .fixedSize()
            .frame(width: 150, height: 150)
            .contentShape(Rectangle())
            .onTapGesture {
                info.calendarType = type
            }.background(
                info.calendarType == type ? Color.blue : Color.clear)
            .cornerRadius(13)
    }
}

struct CalendarView_Previews : PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

struct WidgetOption_Providers: PreviewProvider {
    static var previews: some View {
        ImageOrGifView()
    }
}
