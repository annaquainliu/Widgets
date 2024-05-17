//
//  ImageOrGifView.swift
//  Widgets
//
//  Created by Anna Liu on 7/27/23.
//

import Foundation
import SwiftUI

struct ScreenSaverView: View {
    @EnvironmentObject var store : WidgetStore
    @State var fileName : [URL] = []
    @State var backButtonPressed = false
    @State var info = ScreenWidgetInfo(opacity: 1)
   
    var body: some View {
        if backButtonPressed {
            ContentView()
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    WidgetTypeTab(backButtonPressed: $backButtonPressed, titleText: "Screen Saver")
                    HStack {
                        FilePicker(files: $fileName)
                        Spacer(minLength: 40)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Opacity: ").font(.title).padding()
                                TextField("Enter opacity", value: $info.opacity, format: .number)
                                                .textFieldStyle(.roundedBorder)
                                                .padding()
                            }
                            WidgetMenu(info: $info, fileNames: $fileName)
                        }
                    }
                }.padding()
            }.frame(width: 1200, height: 700)
             
        }
    }
}

struct ScreenSaver_Providers: PreviewProvider {
    static var previews: some View {
        ScreenSaverView()
    }
}

struct ImageOrGifView: View {
    @EnvironmentObject var store : WidgetStore
    @State var fileName : [URL] = []
    @State var backButtonPressed = false
    @State var info = WidgetTypeInfo(type: WidgetTypeInfo.types.image)
    
    var body : some View {
        if backButtonPressed {
            ContentView()
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    WidgetTypeTab(backButtonPressed: $backButtonPressed, titleText: "Image or Gif")
                    Spacer().frame(height: 30)
                    HStack {
                        FilePicker(files: $fileName)
                        Spacer(minLength: 40)
                        WidgetMenu(info: $info, fileNames: $fileName)
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
    @State var info = CalendarInfo(calendarType: CalendarSizes.types.calendar)
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
                        WidgetMenu(info: $info, fileNames: $fileName)
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

struct CountdownView : View {
    @EnvironmentObject var store : WidgetStore
    @State var fileNames : [URL] = []
    @State var backButtonPressed : Bool = false
    @State var info = CountDownWidgetInfo(time: Date(), desc: "")
    let width : CGFloat = 1100
    let height : CGFloat = 700
    
    var body: some View {
        if backButtonPressed {
            ContentView()
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    WidgetTypeTab(backButtonPressed: $backButtonPressed, titleText: "Countdown")
                    VStack {
                        VStack {
                            HStack {
                                Text("Date End").font(.title2).padding()
                                DatePicker(
                                    "",
                                    selection: Binding<Date>(get: {self.info.time }, set: {self.info.time = $0}),
                                    displayedComponents: [.date]
                                ).font(.title)
                                .padding()
                            }
                            HStack {
                                Text("Description").font(.title2).padding()
                                TextField(text: Binding<String>(get: {self.info.desc}, set: {self.info.desc = $0}), prompt: Text("Description of Countdown")) {
                                }
                            }
                        }.frame(width: 700)
                        Spacer(minLength: 30)
                        HStack {
                            FilePicker(files: $fileNames)
                            WidgetMenu(info: $info, fileNames: $fileNames)
                        }
                    }.padding()
                }
            }.frame(width: width, height: height)
            
        }
    }
}

struct TextWidgetView : View {
    @EnvironmentObject var store : WidgetStore
    @State var fileNames : [URL] = []
    let width : CGFloat = 1100
    let height : CGFloat = 700
    @State var backButtonPressed : Bool = false
    @State var info = TextWidgetInfo(text: "", font: "Arial")
    
    var body: some View {
        if backButtonPressed {
            ContentView()
        }
        else {
            ScrollView {
                VStack(alignment: .leading) {
                    WidgetTypeTab(backButtonPressed: $backButtonPressed, titleText: "Text")
                    VStack {
                        HStack {
                            Text("Text: ").font(.title2)
                            TextField(text: Binding<String>(get: {info.text}, set: {info.text = $0}), prompt: Text("Your Text")) {
                            }.padding()
                            Picker("Font: ", selection: Binding<String>(get: {info.font}, set: {info.font = $0})) {
                                ForEach(getAllFonts(), id: \.self) {
                                    Text($0).font(.custom($0, size: 12))
                                }
                            }.font(.title2)
                        }.frame(width: 700)
                        Spacer(minLength: 30)
                        HStack {
                            FilePicker(files: $fileNames)
                            WidgetMenu(info: $info, fileNames: $fileNames)
                        }
                    }
                }.padding()
            }.frame(width: width, height: height)
        }
    }
    
    func getAllFonts() -> [String] {
        let fontFamilies = NSFontManager.shared.availableFontFamilies.sorted()
        return fontFamilies
    }
}

//struct TextWidgetView_Providers: PreviewProvider {
//    static var previews: some View {
//        TextWidgetView()
//    }
//}

//struct CountdownView_Previews : PreviewProvider {
//    static var previews: some View {
//        CountdownView()
//    }
//}

//
//struct CalendarView_Previews : PreviewProvider {
//    static var previews: some View {
//        CalendarView()
//    }
//}
//
//struct WidgetOption_Providers: PreviewProvider {
//    static var previews: some View {
//        ImageOrGifView()
//    }
//}
