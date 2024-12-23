//
//  WidgetMenu.swift
//  Widgets
//
//  Created by Anna Liu on 7/29/23.
//

import Foundation
import SwiftUI

struct Alerts {
    var alertInvalidTimeFrame = false
    var alertInstructions = false
    var nullFileName = false
    var invalidInterval = false
    var invalidTimeFrame = false
}
 
struct TriggersView : View {
    @Binding var triggerSelection : String
    @Binding var weatherSelection : WeatherOptionInfo
    @ObservedObject var staticTimeFrame : StaticTimeFrame
    @Binding var hourSelection : HourTimeFrame
    @Binding var daySelection : WeekdayTimeFrame
    @Binding var dateSelection : DateTimeFrame
    @Binding var monthSelection : MonthTimeFrame
    @Binding var timeFrameSelection : Set<String>
    
    func makeToggle(selected : Binding<Bool>, tag: String) -> some View {
        return Button {
            selected.wrappedValue = !selected.wrappedValue
            if selected.wrappedValue {
                timeFrameSelection.insert(tag)
            } else {
                timeFrameSelection.remove(tag)
            }
        } label: {
            Image(systemName: selected.wrappedValue ? "checkmark.square" : "square")
                .font(.system(size: 30))
        }.buttonStyle(.borderless)
    }
    
    func makeSelection(list: [String]) -> some View {
        ForEach(0..<list.count, id: \.self) { index in
            Text(list[index])
                .tag(index + 1)
        }
    }
    
    var body: some View { 
        VStack(alignment: .leading) {
            Picker(selection: $triggerSelection, label: Text("")) {
                makeRadioOption(
                    title: Triggers.types.always.rawValue,
                    view: HStack {
                        TriggerCategoryText(text: "Always")},
                    selection: triggerSelection)
                makeRadioOption(
                    title: Triggers.types.weather.rawValue,
                    view: HStack {
                        TriggerCategoryText(text: "Weather")
                        Picker("", selection: $weatherSelection) {
                            ForEach(WeatherTrigger.weatherOptions, id: \.self) { item in
                                HStack {
                                    Text("Whenever it is " + item.title.rawValue)
                                    Image(systemName: item.systemImage)
                                }
                            }
                        }.pickerStyle(.menu)
                    },
                    selection: triggerSelection)
                makeRadioOption(title: Triggers.types.staticTimeFrame.rawValue,
                                view: HStack {
                                VStack(alignment: .leading) {
                                    TriggerCategoryText(text: "Time Frame")
                                    Text("(Static)").foregroundColor(.gray).padding(.bottom)
                                }
                                 DatePicker("From", selection: $staticTimeFrame.timeStart, displayedComponents: [.hourAndMinute, .date])
                                DatePicker("To", selection: $staticTimeFrame.timeEnd, displayedComponents: [.hourAndMinute, .date])
                                },
                                selection: triggerSelection)
                makeRadioOption(
                    title: Triggers.types.timeFrame.rawValue,
                    view: HStack {
                        VStack(alignment: .leading) {
                            TriggerCategoryText(text: "Time Frame")
                            Text("(Repeated)").foregroundColor(.gray).padding(.bottom)
                        }
                        List {
                            Text("Note: All selected time frames will repeat.").foregroundColor(.gray)
                            HStack {
                                makeToggle(selected: $hourSelection.selected, tag: TimeFrame.hour)
                                HStack {
                                    Text("Hour").padding()
                                    DatePicker("From", selection: $hourSelection.timeStart, displayedComponents: [.hourAndMinute])
                                    DatePicker("To", selection: $hourSelection.timeEnd, displayedComponents: [.hourAndMinute])
                                }.disabled(!hourSelection.selected)
                            }
                            HStack {
                                makeToggle(selected: $daySelection.selected, tag: TimeFrame.dayOfTheWeek)
                                HStack {
                                    Text("Day").padding()
                                    Picker("From", selection: $daySelection.timeStart) {
                                        makeSelection(list: TimeFrame.weekdays)
                                    }.pickerStyle(.menu)
                                    Picker("To", selection: $daySelection.timeEnd) {
                                        makeSelection(list: TimeFrame.weekdays)
                                    }.pickerStyle(.menu)
                                }.disabled(!daySelection.selected)
                            }
                            HStack {
                                makeToggle(selected: $dateSelection.selected, tag: TimeFrame.dayOfTheMonth)
                                HStack {
                                    Text("Day Of the Month").padding()
                                    Picker("From", selection: $dateSelection.timeStart) {
                                        ForEach(1..<32) { date in
                                            Text("\(date)")
                                        }
                                    }.pickerStyle(.menu)
                                    Picker("To", selection: $dateSelection.timeEnd) {
                                        ForEach(1..<32) { date in
                                            Text("\(date)")
                                        }
                                    }.pickerStyle(.menu)
                                    
                                }.disabled(!dateSelection.selected)
                            }
                            HStack {
                                makeToggle(selected: $monthSelection.selected, tag: TimeFrame.month)
                                HStack {
                                    Text("Month").padding()
                                    Picker("From", selection: $monthSelection.timeStart) {
                                        makeSelection(list: TimeFrame.months)
                                    }.pickerStyle(.menu)
                                    Picker("To", selection: $monthSelection.timeEnd) {
                                        makeSelection(list: TimeFrame.months)
                                    }.pickerStyle(.menu)
                                    
                                }.disabled(!monthSelection.selected)
                            }
                        }.frame(height: 200)
                    },
                    selection: triggerSelection)
            }.pickerStyle(RadioGroupPickerStyle())
        }.padding([.leading, .trailing])
    }
}

struct WidgetMenu< T : WidgetTypeInfo> : View {
    @State private var triggerSelection = Triggers.types.always.rawValue
    @State var weatherSelection = WeatherOptionInfo(title: WeatherTrigger.types.sunny, systemImage: "sun.min.fill")
    @State var timeFrameSelection = Set<String>()
    @State var hourSelection = HourTimeFrame()
    @State var daySelection = WeekdayTimeFrame()
    @State var dateSelection = DateTimeFrame()
    @State var monthSelection = MonthTimeFrame()
    @StateObject var staticTimeFrame = StaticTimeFrame(timeStart: Date(), timeEnd: Date())
    @State private var alerts = Alerts()
    @State private var slideshowOptions = SlideshowInfo(interval: 1)
    
    @ObservedObject var info : T
    @Binding var fileNames : [URL]
    
    @EnvironmentObject var store : WidgetStore
    @EnvironmentObject var displayDesktop: DisplayDesktopWidgets

    
    var body : some View {
        VStack(alignment: .leading) {
            if fileNames.count > 1 {
                SlideShowView(options: $slideshowOptions)
            }
            HStack {
                Text("Triggers").font(.title).padding()
                Text("*When should the widget be visible?*").font(.title3)
            }
            TriggersView(triggerSelection: $triggerSelection, weatherSelection: $weatherSelection, staticTimeFrame: staticTimeFrame,
                         hourSelection: $hourSelection, daySelection: $daySelection, dateSelection: $dateSelection, monthSelection: $monthSelection, timeFrameSelection: $timeFrameSelection)
            VStack {
                Spacer().frame(height: 4)
                HStack {
                    Spacer()
                    Button("Create Widget") {
                        if triggerSelection == Triggers.types.staticTimeFrame.rawValue &&
                            staticTimeFrame.timeStart > staticTimeFrame.timeEnd {
                            alerts.alertInvalidTimeFrame = true
                            return
                        }
                        if fileNames.count == 0 {
                            alerts.nullFileName = true
                            return
                        }
                        if slideshowOptions.interval == 0 {
                            alerts.invalidInterval = true
                            return
                        }
                        var trigger : Triggers;
                        if triggerSelection == Triggers.types.timeFrame.rawValue {
                            let hourParam = timeFrameSelection.contains(TimeFrame.hour) ? hourSelection : nil
                            let dayParam = timeFrameSelection.contains(TimeFrame.dayOfTheWeek) ? daySelection : nil
                            let dateParam = timeFrameSelection.contains(TimeFrame.dayOfTheMonth) ? dateSelection : nil
                            let monthParam = timeFrameSelection.contains(TimeFrame.month) ? monthSelection : nil
                            let timeFrame = TimeFrameInfo(Hour: hourParam, Weekday: dayParam, Date: dateParam, Month: monthParam)
                            if timeFrame.getEndingTime() == nil || timeFrame.getStartingTime() == nil {
                                alerts.invalidTimeFrame = true
                                return
                            }
                            trigger = timeFrame
                        }
                        else if triggerSelection == Triggers.types.weather.rawValue {
                            trigger = WeatherTrigger(weather: weatherSelection.title)
                        }
                        else if triggerSelection == Triggers.types.staticTimeFrame.rawValue {
                            trigger = staticTimeFrame
                        }
                        else {
                            trigger = Triggers(type: Triggers.types.always)
                        }
                        let widgetInfo = WidgetInfo(info: info, trigger: trigger, imageURLs: fileNames,
                                                    slideshow: slideshowOptions)
                        _ = ScreenWindowController(widget: widgetInfo, displayDesktop: displayDesktop, store: store)
                        alerts.alertInstructions = true
                    }
                    .padding(40)
                    .alert("You can click on the widget to drag it or resize it (resizing is only available for image/gif widgets). \n\n To delete the widget, press the x mark on the top left. \n\n To save changes, press the 'Save Changes' button.", isPresented: $alerts.alertInstructions) {
                        Button("OK", role: .cancel) { }
                    }
                    .alert("The start time for the Static Time Frame should be before the end time.", isPresented: $alerts.alertInvalidTimeFrame) {
                        Button("OK", role: .cancel) { }
                    }
                    .alert("Please import a photo", isPresented: $alerts.nullFileName) {
                        Button("OK", role: .cancel) { }
                    }
                    .alert("The interval cannot be 0.", isPresented: $alerts.invalidInterval) {
                        Button("OK", role: .cancel) {}
                    }
                    .alert("The time intervals are invalid.", isPresented: $alerts.invalidTimeFrame) {
                        Button("OK", role: .cancel) {}
                    }
                }
            }
        }
    }
}

struct SlideShowView : View {
    @Binding var options : SlideshowInfo
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Slideshow Options").font(.title).padding()
                Text("*How often should the background change?*").font(.title3).padding()
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Interval").font(.title2).padding(.trailing)
                    Text("Every")
                    TextField("", value: $options.interval, format: .number)
                        .textFieldStyle(.roundedBorder)
                    Text("Minute")
                }.frame(width: 300)
            }.padding(.leading)
        }
    }
}
