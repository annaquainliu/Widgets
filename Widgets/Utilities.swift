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

struct CalendarView : View {
    @State var selection = Date()
    var scale: CGFloat
    @FocusState var isFocused : Bool
    
    var body: some View {
        DatePicker("", selection: Binding(get: {selection}, set: {
                selection = $0
                isFocused = false 
             }), displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .scaleEffect(scale, anchor: .leading)
            .frame(width: 156.5 * scale, height: 168 * scale, alignment: .center)
            .focused($isFocused)
    }
}


struct CalendarView_Providers: PreviewProvider {
    static var previews: some View {
        CalendarView(scale: 1.7857142857142858)
    }
}

//struct CalendarImage_Providers: PreviewProvider {
//    static var previews: some View {
//        CalendarImage(image: NSImage(contentsOf: URL(filePath: "/Users/annaliu/Downloads/christmas.gif"))!, size: NSSize(width: 234.75, height: 252.0), scale: 0.84)
//    }
//}
