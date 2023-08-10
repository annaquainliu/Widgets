//
//  WidgetMenu.swift
//  Widgets
//
//  Created by Anna Liu on 7/29/23.
//

import Foundation
import SwiftUI

struct WidgetMenu : View {
    @State private var triggerSelection = Triggers.always
    @State var weatherSelection =  WeatherOptionInfo(title: WeatherTrigger.sunny, systemImage: "sun.min.fill")
    @State private var alertInstructions = false
    @State var timeFrameSelection = Set<String>()
    @State var hourSelection = HourTimeFrame()
    @State var daySelection = WeekdayTimeFrame()
    @State var dateSelection = DateTimeFrame()
    @State var monthSelection = MonthTimeFrame()
    
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
        }
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
                    makeRadioOption(
                        title: Triggers.loc,
                        view: HStack {
                            TriggerCategoryText(text: Triggers.loc)
                    }, selection: triggerSelection)
                    makeRadioOption(
                        title: Triggers.timeFrame,
                        view: HStack {
                            TriggerCategoryText(text: "Time Frame")
                            List {
                                Text("Note: All selected time frames will repeat. *E.g.: 10:40AM-2PM will repeat every day*")
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
                            }
                        },
                        selection: triggerSelection)
                }.pickerStyle(RadioGroupPickerStyle())
            }.padding([.leading, .trailing])
            VStack {
                Spacer().frame(height: 4)
                HStack {
                    Spacer()
                    Button("Create Widget") {
                        // order matters!
                        let hourParam = timeFrameSelection.contains(TimeFrame.hour) ? hourSelection : nil
                        let dayParam = timeFrameSelection.contains(TimeFrame.dayOfTheWeek) ? daySelection : nil
                        let dateParam = timeFrameSelection.contains(TimeFrame.dayOfTheMonth) ? dateSelection : nil
                        let monthParam = timeFrameSelection.contains(TimeFrame.month) ? monthSelection : nil
                        let timeFrame = TimeFrameInfo(Hour: hourParam, Weekday: dayParam, Date: dateParam, Month: monthParam)
                        _ = WidgetViewModel(
                            triggerType: triggerSelection,
                            timeFrame: timeFrame,
                            weather: weatherSelection.title,
                            store: store,
                            displayDesktop: displayDesktop)
                        alertInstructions = true
                    }
                    .padding(40)
                    .alert("You can click on the widget to drag it or resize it. \n\n To delete the widget, press the x mark on the top left. \n\n To save changes, press the 'Save Changes' button.", isPresented: $alertInstructions) {
                        Button("OK", role: .cancel) { }
                    }
                }
            }
        }
    }
}

struct WidgetMenu_Providers: PreviewProvider {
    static var previews: some View {
        WidgetMenu().frame(width: 1000)
    }
}
