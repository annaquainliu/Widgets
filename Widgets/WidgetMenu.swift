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
    @State var timeFrameSelection = Set<String>()
    @State var hourSelection = TimeFrameInfo(type: TimeFrame.hour)
    @State var daySelection = TimeFrameInfo(type: TimeFrame.dayOfTheWeek)
    @State var dateSelection = TimeFrameInfo(type: TimeFrame.dayOfTheMonth)
    @State var monthSelection = TimeFrameInfo(type: TimeFrame.month)
    
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
            if selected.wrappedValue {
                Image(systemName: "checkmark.square")
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
                                    makeToggle(selected: $hourSelection.selected, tag: TimeFrame.hour)
                                    HStack {
                                        Text("Hour").padding()
                                        DatePicker("From", selection: $hourSelection.dateTimeStart, displayedComponents: [.hourAndMinute])
                                        DatePicker("To", selection: $hourSelection.dateTimeEnd, displayedComponents: [.hourAndMinute])
                                    }.disabled(!hourSelection.selected)
                                }
                                HStack {
                                    makeToggle(selected: $daySelection.selected, tag: TimeFrame.dayOfTheWeek)
                                    HStack {
                                        Text("Day").padding()
                                        Picker("From", selection: $daySelection.stringTimeStart) {
                                            ForEach(TimeFrame.weekdays, id: \.self) {item in
                                                Text(item)
                                            }
                                        }.pickerStyle(.menu)
                                        Picker("To", selection: $daySelection.stringTimeEnd) {
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
                                        Picker("From", selection: $dateSelection.intTimeStart) {
                                            ForEach(1..<32) { date in
                                                Text("\(date)")
                                            }
                                        }.pickerStyle(.menu)
                                        Picker("To", selection: $dateSelection.intTimeEnd) {
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
                                        Picker("From", selection: $monthSelection.stringTimeStart) {
                                            ForEach(TimeFrame.months, id: \.self) {item in
                                                Text(item)
                                            }
                                        }.pickerStyle(.menu)
                                        Picker("To", selection: $monthSelection.stringTimeEnd) {
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
                        let map : [String : TimeFrameInfo] = [
                            TimeFrame.month: monthSelection,
                            TimeFrame.dayOfTheMonth: dateSelection,
                            TimeFrame.dayOfTheWeek: daySelection,
                            TimeFrame.hour: hourSelection]
                        var timeFrames : [TimeFrameInfo] = []
                        // order matters!
                        for selection in timeFrameSelection {
                            timeFrames.append(map[selection]!)
                        }
                        _ = WidgetViewModel(
                            triggerType: triggerSelection,
                            timeFrame: timeFrames,
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
