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
    @State var weatherSelection =  WeatherOptionInfo(title: WeatherOptionInfo.sunny, systemImage: "sun.min.fill")
    @State private var alertInstructions = false
    @State var selection = Set<String>()
    @State var hourSelection = TimeFrameSelection(type: TimeFrameList.hour)
    @State var daySelection = TimeFrameSelection(type: TimeFrameList.dayOfTheWeek)
    @State var dateSelection = TimeFrameSelection(type: TimeFrameList.dayOfTheMonth)
    @State var monthSelection = TimeFrameSelection(type: TimeFrameList.month)
    
    @EnvironmentObject var store : WidgetStore
    @EnvironmentObject var displayDesktop: DisplayDesktopWidgets
    
    func makeToggle(selected : Binding<Bool>, tag: String) -> some View {
        return Button {
            selected.wrappedValue = !selected.wrappedValue
            if selected.wrappedValue {
                selection.insert(tag)
            } else {
                selection.remove(tag)
            }
            print(selection)
        } label: {
            if selected.wrappedValue {
                Image(systemName: "checkmark")
            }
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
                                HStack {
                                    makeToggle(selected: $hourSelection.selected, tag: TimeFrameList.hour)
                                    HStack {
                                        Text("Hour").padding()
                                        DatePicker("From", selection: $hourSelection.dateTimeStart, displayedComponents: [.hourAndMinute])
                                        DatePicker("To", selection: $hourSelection.dateTimeEnd, displayedComponents: [.hourAndMinute])
                                        Toggle("Repeat", isOn: $hourSelection.doRepeat)
                                    }.disabled(!hourSelection.selected)
                                }
                                HStack {
                                    makeToggle(selected: $daySelection.selected, tag: TimeFrameList.dayOfTheWeek)
                                    HStack {
                                        Text("Day").padding()
                                        Picker("From", selection: $daySelection.stringTimeStart) {
                                            ForEach(TimeFrameList.weekdays, id: \.self) {item in
                                                Text(item)
                                            }
                                        }.pickerStyle(.menu)
                                        Picker("To", selection: $daySelection.stringTimeEnd) {
                                            ForEach(TimeFrameList.weekdays, id: \.self) {item in
                                                Text(item)
                                            }
                                        }.pickerStyle(.menu)
                                        Toggle("Repeat", isOn: $daySelection.doRepeat)
                                    }.disabled(!daySelection.selected)
                                }
                                HStack {
                                    makeToggle(selected: $monthSelection.selected, tag: TimeFrameList.month)
                                    HStack {
                                        Text("Month").padding()
                                        Picker("From", selection: $monthSelection.stringTimeStart) {
                                            ForEach(TimeFrameList.months, id: \.self) {item in
                                                Text(item)
                                            }
                                        }.pickerStyle(.menu)
                                        Picker("To", selection: $monthSelection.stringTimeEnd) {
                                            ForEach(TimeFrameList.months, id: \.self) {item in
                                                Text(item)
                                            }
                                        }.pickerStyle(.menu)
                                        Toggle("Repeat", isOn: $monthSelection.doRepeat)
                                    }.disabled(!monthSelection.selected)
                                }
                                HStack {
                                    makeToggle(selected: $dateSelection.selected, tag: TimeFrameList.dayOfTheMonth)
                                    HStack {
                                        Text("Date").padding()
                                        DatePicker("From", selection: $dateSelection.dateTimeStart, displayedComponents: [.date])
                                        DatePicker("To", selection: $dateSelection.dateTimeEnd, displayedComponents: [.date])
                                        Toggle("Repeat", isOn: $dateSelection.doRepeat)
                                    }.disabled(!dateSelection.selected)
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
//                        _ = WidgetViewModel(
//                            triggerType: triggerSelection,
//                            timeFrame: TimeFrame(timeRange: [timeFrameStart, timeFrameEnd]),
//                            weather: weatherSelection.title,
//                            store: store,
//                            displayDesktop: displayDesktop)
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
