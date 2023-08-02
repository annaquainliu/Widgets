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
    @State private var duration = 0
    @State private var durationMeasurement = TimeOptions.s
    @State private var durationSelection = Duration.untilDeactivate
    @State var weatherSelection =  WeatherOptionInfo(title: WeatherOptionInfo.sunny, systemImage: "sun.min.fill")
    @State private var freqMeasurement = TimeOptions.s
    @State private var frequency = 0
    @State private var frequencyStartDate = Date()
    @State private var timeFrameSelection = TimeFrame.always
    @State private var timeFrameStart = Date()
    @State private var timeFrameEnd = Date()
    @State private var alertInstructions = false
    
    func makeDurationView() -> some View {
        return HStack {
            TextField("Enter the time value", value: $duration, format: .number)
                .textFieldStyle(.roundedBorder)
            TimeOptions.makeTimeMeasurementMenu(selection: $durationMeasurement)
        }.frame(width: 400)
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
                        title: Triggers.freq,
                        view: HStack {
                            TriggerCategoryText(text: Triggers.freq)
                            Text("Every").font(.title2)
                            TextField("Enter the time value", value: $frequency, format: .number)
                                           .textFieldStyle(.roundedBorder)
                            TimeOptions.makeTimeMeasurementMenu(selection: $freqMeasurement)
                            Text("starting from").font(.title2)
                            DatePicker(
                                    "",
                                    selection: $frequencyStartDate,
                                    displayedComponents: [.date, .hourAndMinute]
                        )},
                        selection: triggerSelection)
                    makeRadioOption(
                        title: Triggers.loc,
                        view: HStack {
                            TriggerCategoryText(text: Triggers.loc)
                    }, selection: triggerSelection)
                }.pickerStyle(RadioGroupPickerStyle())
            }.padding([.leading, .trailing])
            HStack {
                Text("Duration").font(.title).padding()
                Text("*The widget should appear after how long?*").font(.title3)
            }
            VStack {
                if triggerSelection == Triggers.freq {
                    makeDurationView()
                } else {
                    Picker(selection: $durationSelection, label: Text("")) {
                        makeRadioOption(
                            title: Duration.untilDeactivate,
                            view: Text("Until the trigger is deactivated").font(.title2),
                            selection: durationSelection)
                        makeRadioOption(
                            title: Duration.duration,
                            view: makeDurationView(),
                            selection: durationSelection)
                    }.pickerStyle(RadioGroupPickerStyle())
                }
            }.padding([.leading, .trailing])
             .disabled(triggerSelection == "Always")
            VStack(alignment: .leading) {
                HStack {
                    Text("Time Frame").font(.title).padding()
                    Text("*When should the widget be triggerable?*").font(.title3)
                }
                VStack {
                    Picker(selection: $timeFrameSelection, label: Text("")) {
                        makeRadioOption(
                            title: TimeFrame.always,
                            view: Text("Always").font(.title2),
                            selection: timeFrameSelection)
                        makeRadioOption(
                            title: TimeFrame.frame,
                            view: HStack {
                                DatePicker(
                                    "From:",
                                    selection: $timeFrameStart,
                                    displayedComponents: [.date]
                                )
                                DatePicker(
                                    "End:",
                                    selection: $timeFrameEnd,
                                    displayedComponents: [.date]
                                )
                            },
                            selection: timeFrameSelection)
                    }.pickerStyle(RadioGroupPickerStyle())
                }.padding([.leading, .trailing])
            }
            VStack {
                Spacer().frame(height: 4)
                HStack {
                    Spacer()
                    Button("Create Widget") {
                        Task {
                            _ = WidgetViewModel(
                                triggerType: triggerSelection,
                                duration: Duration(
                                    durationSelection: durationSelection,
                                    durationMeasurement: durationMeasurement,
                                    duration: duration),
                                timeFrame: TimeFrame(selection: timeFrameSelection,
                                                     timeRange: [timeFrameStart, timeFrameEnd]),
                                weather: weatherSelection.title,
                                freq: Frequency(
                                    measurement: freqMeasurement,
                                    frequency: frequency,
                                    startDate: frequencyStartDate))
                        }
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
