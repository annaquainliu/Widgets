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
}

struct WidgetMenu : View {
    var type : WidgetInfo.types
    @State private var triggerSelection = Triggers.always
    @State var weatherSelection =  WeatherOptionInfo(title: WeatherTrigger.sunny, systemImage: "sun.min.fill")
    @State var timeFrameSelection = Set<String>()
    @State var hourSelection = HourTimeFrame()
    @State var daySelection = WeekdayTimeFrame()
    @State var dateSelection = DateTimeFrame()
    @State var monthSelection = MonthTimeFrame()
    @State var staticTimeFrame = StaticTimeFrame(timeStart: Date(), timeEnd: Date())
    @State private var alerts = Alerts()
    
    @Binding var info : WidgetTypeInfo
    @Binding var fileNames : [URL]
    
    @EnvironmentObject var store : WidgetStore
    @EnvironmentObject var displayDesktop: DisplayDesktopWidgets
    
    func makeToggle(selected : Binding<Bool>, tag: String) -> some View {
        return Button {
            selected.wrappedValue = !selected.wrappedValue
            if selected.wrappedValue {
                timeFrameSelection.insert(tag)
            } else {
                timeFrameSelection.remove(tag)
            }
            print(timeFrameSelection)
        } label: {
            Image(systemName: selected.wrappedValue ? "checkmark.square" : "square")
                .font(.system(size: 30))
        }.buttonStyle(.borderless)
    }
    
    var body : some View {
        VStack(alignment: .leading) {
            Triggers.triggerDescription()
            VStack(alignment: .leading) {
                Picker(selection: $triggerSelection, label: Text("")) {
                    makeRadioOption(
                        title: Triggers.always,
                        view: HStack {
                            TriggerCategoryText(text: Triggers.always)},
                        selection: triggerSelection)
                    makeRadioOption(
                        title: Triggers.weather,
                        view: HStack {
                            TriggerCategoryText(text: "Weather")
                            Picker("", selection: $weatherSelection) {
                                ForEach(WeatherTrigger.weatherOptions, id: \.self) { item in
                                    HStack {
                                        Text("Whenever it is " + item.title)
                                        Image(systemName: item.systemImage)
                                    }
                                }
                            }.pickerStyle(.menu)
                        },
                        selection: triggerSelection)
                    makeRadioOption(title: Triggers.staticTimeFrame,
                                    view: HStack {
                                    VStack(alignment: .leading) {
                                        TriggerCategoryText(text: "Time Frame")
                                        Text("(Static)").padding(.bottom)
                                    }
                                     DatePicker("From", selection: $staticTimeFrame.timeStart, displayedComponents: [.hourAndMinute, .date])
                                    DatePicker("To", selection: $staticTimeFrame.timeEnd, displayedComponents: [.hourAndMinute, .date])
                                    },
                                    selection: triggerSelection)
                    makeRadioOption(
                        title: Triggers.timeFrame,
                        view: HStack {
                            VStack(alignment: .leading) {
                                TriggerCategoryText(text: "Time Frame")
                                Text("(Repeated)").padding(.bottom)
                            }
                            List {
                                Text("Note: All selected time frames will repeat.")
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
                                            ForEach(TimeFrame.weekdays, id: \.self) {item in
                                                Text(item)
                                            }
                                        }.pickerStyle(.menu)
                                        Picker("To", selection: $daySelection.timeEnd) {
                                            ForEach(TimeFrame.weekdays, id: \.self) {item in
                                                Text(item)
                                            }
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
                                            ForEach(TimeFrame.months, id: \.self) {item in
                                                Text(item)
                                            }
                                        }.pickerStyle(.menu)
                                        Picker("To", selection: $monthSelection.timeEnd) {
                                            ForEach(TimeFrame.months, id: \.self) {item in
                                                Text(item)
                                            }
                                        }.pickerStyle(.menu)
                                        
                                    }.disabled(!monthSelection.selected)
                                }
                            }.frame(height: 200)
                        },
                        selection: triggerSelection)
                }.pickerStyle(RadioGroupPickerStyle())
            }.padding([.leading, .trailing])
            VStack {
                Spacer().frame(height: 4)
                HStack {
                    Spacer()
                    Button("Create Widget") {
                        if triggerSelection == Triggers.staticTimeFrame &&
                            staticTimeFrame.timeStart > staticTimeFrame.timeEnd {
                            alerts.alertInvalidTimeFrame = true
                            return
                        }
                        if fileNames.count == 0 && type == WidgetInfo.types.image {
                            alerts.nullFileName = true
                            return
                        }
                        var timeFrame : TimeFrameInfo? = nil
                        if triggerSelection == Triggers.timeFrame {
                            let hourParam = timeFrameSelection.contains(TimeFrame.hour) ? hourSelection : nil
                            let dayParam = timeFrameSelection.contains(TimeFrame.dayOfTheWeek) ? daySelection : nil
                            let dateParam = timeFrameSelection.contains(TimeFrame.dayOfTheMonth) ? dateSelection : nil
                            let monthParam = timeFrameSelection.contains(TimeFrame.month) ? monthSelection : nil
                            timeFrame = TimeFrameInfo(Hour: hourParam, Weekday: dayParam, Date: dateParam, Month: monthParam)
                        }
                        
                        let widgetInfo = WidgetInfo(triggerType: triggerSelection,
                                                    weather:  triggerSelection == Triggers.weather ? weatherSelection.title : nil,
                                                    timeFrame: timeFrame,
                                                    staticTimeFrame: triggerSelection == Triggers.staticTimeFrame ? staticTimeFrame : nil,
                                                    imageName: fileNames,
                                                    type: type,
                                                    info: info)
                        
                        _ = ScreenWindowController(widget: widgetInfo, displayDesktop: displayDesktop, store: store)
                        alerts.alertInstructions = true
                    }
                    .padding(40)
                    .alert("You can click on the widget to drag it or resize it. \n\n To delete the widget, press the x mark on the top left. \n\n To save changes, press the 'Save Changes' button.", isPresented: $alerts.alertInstructions) {
                        Button("OK", role: .cancel) { }
                    }
                    .alert("The start time for the Static Time Frame should be before the end time.", isPresented: $alerts.alertInvalidTimeFrame) {
                        Button("OK", role: .cancel) { }
                    }
                    .alert("Please import a photo", isPresented: $alerts.nullFileName) {
                        Button("OK", role: .cancel) { }
                    }
                }
            }
        }
    }
}
