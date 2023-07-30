//
//  WidgetMenu.swift
//  Widgets
//
//  Created by Anna Liu on 7/29/23.
//

import Foundation
import SwiftUI

struct WidgetMenu : View {
    @State private var triggerSelection = "Always"
    @State private var duration = 0
    @State private var durationMeasurement = TimeOptions.s
    @State private var durationSelection = Duration.untilDeactivate
    
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
                        view: WeatherTrigger(),
                        selection: triggerSelection)
                    makeRadioOption(
                        title: Triggers.freq,
                        view: FrequencyTrigger(),
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
            TimeFrame()
        }
    }
}
