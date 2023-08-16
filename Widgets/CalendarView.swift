//
//  CalendarView.swift
//  Widgets
//
//  Created by Anna Liu on 8/15/23.
//

import Foundation
import SwiftUI

struct CalendarView : View {
    
    @EnvironmentObject var store : WidgetStore
    @State var fileName : URL? = nil
    @State var selection : Date = Date()
    @State var backButtonPressed : Bool = false
    @State var calendarTypes = Set<CalendarSizes.types>()
    let width : CGFloat = 1300
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
                                makeCalendarButton(view: Image(systemName: "calendar").font(.system(size: 100)), type: CalendarSizes.types.calendar)
                               makeCalendarButton(view: Image(systemName: "clock.fill").font(.system(size: 100)), type: CalendarSizes.types.clock)
                            }
                        }
                        Spacer().frame(width: width / 5)
                        VStack {
                            Text("Background").font(.title)
                            FilePicker(filename: $fileName)
                        }
                    }.frame(width: width)
                    Spacer().frame(height: 30)
                    HStack {
                        Spacer(minLength: 40)
                        WidgetMenu(type: WidgetInfo.types.calendar, fileName: $fileName)
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
                if calendarTypes.contains(type) {
                    calendarTypes.remove(type)
                } else {
                    calendarTypes.insert(type)
                }
            }.background(
                calendarTypes.contains(type) ? Color.blue : Color.clear)
            .cornerRadius(13)
    }
}

struct CalendarView_Previews : PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
