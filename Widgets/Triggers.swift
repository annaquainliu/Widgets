//
//  Triggers.swift
//  Widgets
//
//  Created by Anna Liu on 7/29/23.
//

import Foundation
import SwiftUI

struct TimeOptions {
    static var s = "seconds"
    static var ms = "milliseconds"
    static var min = "minutes"
    static var hr = "hours"
    static var day = "days"
    static var week = "weeks"
    static var month = "months"
    static var year = "years"
    static var timeMeasurements = [TimeOptions.ms, TimeOptions.s, TimeOptions.min, TimeOptions.hr, TimeOptions.day, TimeOptions.week, TimeOptions.month, TimeOptions.year]
    
    static func makeTimeMeasurementMenu(selection : Binding<String>) -> some View {
        return Picker("", selection: selection) {
            ForEach(TimeOptions.timeMeasurements, id: \.self) { item in
                Text(item)
            }
        }.pickerStyle(MenuPickerStyle())
    }
}

struct WeatherTrigger : View {
    
    struct weatherOptionInfo : Hashable {
        var title : String;
        var systemImage : String;
    }
    
    @State private var weatherSelection =  weatherOptionInfo(title: "sunny", systemImage: "sun.min.fill")
    
    var weatherOptions = [
        weatherOptionInfo(title: "sunny", systemImage: "sun.min.fill"),
        weatherOptionInfo(title: "cloudy", systemImage: "cloud.fill"),
        weatherOptionInfo(title: "raining", systemImage:  "cloud.heavyrain.fill"),
        weatherOptionInfo(title: "windy", systemImage: "wind.circle"),
        weatherOptionInfo(title: "snowing", systemImage: "cloud.snow.fill"),
        weatherOptionInfo(title: "thundering", systemImage: "cloud.bolt.rain")]
    
    var body : some View {
        HStack {
            TriggerCategoryText(text: "Weather")
            Picker("", selection: $weatherSelection) {
                ForEach(weatherOptions, id: \.self) { item in
                    HStack {
                        Text("Whenever it is " + item.title)
                        Image(systemName: item.systemImage)
                    }
                }
            }.pickerStyle(.menu)
        }
    }
    
    func getWeather() -> weatherOptionInfo {
        return weatherSelection;
    }

}

struct FrequencyTrigger : View {
    struct FrequencyInfo {
        var freqMeasurement : String
        var frequency : Int
        var frequencyStartDate : Date
    }
    
    @State private var freqMeasurement = TimeOptions.s
    @State private var frequency = 0
    @State private var frequencyStartDate = Date()
    
    var body : some View {
        HStack {
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
        )}
    }
    
    func getFrequencyInfo() -> FrequencyInfo {
        return FrequencyInfo(freqMeasurement: freqMeasurement,
                             frequency: frequency,
                             frequencyStartDate: frequencyStartDate)
    }
}

struct Triggers {
    static var always = "Always"
    static var weather = "Weather"
    static var freq = "Frequency"
    static var loc = "Location"
    
    static func triggerDescription() -> some View {
        return HStack {
            Text("Triggers").font(.title).padding()
            Text("*When should the widget be visible?*").font(.title3)
        }
    }
}

struct Duration {
    static var untilDeactivate = "UntilDeactivated"
    static var duration  = "duration"
}

struct TimeFrame : View {
    struct TimeFrameInfo {
        var timeFrameSelection : String
        var timeFrame : [Date]
    }

    @State private var timeFrameSelection = "Always"
    @State private var timeFrameStart = Date()
    @State private var timeFrameEnd = Date()
    
    static var always = "Always"
    static var frame = "timeFrame"
    
    var body : some View {
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
    }
    
    func getTimeFrameInfo() -> TimeFrameInfo {
        return TimeFrameInfo(timeFrameSelection: timeFrameSelection,
                             timeFrame: [timeFrameStart, timeFrameEnd])
    }
    
}
