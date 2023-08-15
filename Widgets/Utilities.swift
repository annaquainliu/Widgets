//
//  Utilities.swift
//  Widgets
//
//  Created by Anna Liu on 7/27/23.
//

import Foundation
import SwiftUI

func TitleText(text : String) -> some View {
    return Text(text)
        .bold()
        .padding()
        .font(.system(size: 50, design: .rounded)
            .weight(.heavy))
}

struct WidgetTypeTab : View {
    @Binding var backButtonPressed : Bool
    var titleText : String
    
    var body: some View {
        HStack {
            Button {
                backButtonPressed = true
            } label : {
                Image(systemName: "chevron.backward.square.fill")
                    .font(.system(size: 30, weight: .heavy))
            }.padding()
            .padding([.leading, .trailing], 20)
            .buttonStyle(.borderless)
            TitleText(text : titleText)
        }
    }
}

func ImportPhoto() -> some View {
    return VStack {
        Text("Import a photo/gif").font(.headline)
        Image(systemName: "photo.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 32.0, height: 32.0)
    }.frame(width: 150, height: 150)
    .overlay(RoundedRectangle(cornerRadius: 16)
        .stroke(.white, lineWidth: 2))
    .contentShape(Rectangle())
}

func ImportMultiplePhotos() -> some View {
    return VStack {
        Text("Import multiple photos").font(.headline)
        Image(systemName: "photo.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 32.0, height: 32.0)
    }.contentShape(Rectangle())
     .frame(width: 150, height: 150)
     .overlay(RoundedRectangle(cornerRadius: 16)
        .stroke(.white, lineWidth: 2))
}

func TriggerCategoryText(text : String) -> some View {
    return Text(text)
                .font(.title2)
                .frame(width: 100, alignment: .leading)
                .padding(5)
}

func makeRadioOption(title : String, view : some View, selection : String) -> some View {
    return view.tag(title).disabled(selection != title)
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    func startOfMonth(month: Int) -> Date {
        var comp = Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: self))
        comp.month = month
        return Calendar.current.date(from: comp)!
    }
    
    func endOfMonth(month: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: month, day: -1), to: self.startOfMonth(month: month))!
    }
}

func alertMessage(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    return alert.runModal() == .alertFirstButtonReturn
}

struct CalendarIcon : View {
    @State var selection = Date()
    @FocusState var isFocused : Bool
    
    var body: some View {
            DatePicker("", selection: Binding(get: {selection}, set: {
                selection = $0
                isFocused = false
            }), displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .scaleEffect(CalendarSizes.scale, anchor: .leading)
            .frame(width: CalendarSizes.calWidth, height: CalendarSizes.calHeight)
            .focused($isFocused)
            .accentColor(.white)
    }
}

struct ClockIcon : View {
    @State var selection = Date()
    @FocusState var isFocused : Bool
    
    var body: some View {
        DatePicker("", selection: Binding(get: {selection}, set: {
            selection = $0
            isFocused = false
        }), displayedComponents: [.hourAndMinute])
        .datePickerStyle(.graphical)
        .scaleEffect(CalendarSizes.scale, anchor: .leading)
        .frame(width: CalendarSizes.clockWidth, height: CalendarSizes.clockHeight)
        .focused($isFocused)
        .accentColor(.white)
        .labelsHidden()
    }
}

struct CalendarSizes {
    static var calWidth = 156.5 * CalendarSizes.scale
    static var calHeight = 168.0 * CalendarSizes.scale
    static var clockWidth = 120 * CalendarSizes.scale
    static var clockHeight = 120 * CalendarSizes.scale
    static var scale = 1.5
    
    enum types {
        case calendar, clock, both
    }
}

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

struct CalendarView_Providers: PreviewProvider {
    static var previews: some View {
        CalendarIcon()
    }
}

struct ClockView_Providers: PreviewProvider {
    static var previews: some View {
        ClockIcon()
    }
}
