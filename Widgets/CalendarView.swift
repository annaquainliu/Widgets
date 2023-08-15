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
                                DatePicker("", selection: $selection, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .fixedSize()
                                DatePicker("", selection: $selection, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.graphical)
                                .fixedSize()
                            }
                        }
                        Spacer().frame(width: width / 4)
                        FilePicker(filename: $fileName)
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
}

struct CalendarView_Previews : PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
