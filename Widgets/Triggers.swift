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

struct WeatherOptionInfo : Hashable {
    var title : String;
    var systemImage : String;
    static var sunny = "sunny"
    static var cloudy = "cloudy"
    static var raining = "raining"
    static var windy = "windy"
    static var snowing = "snowing"
    static var thunder = "thundering"
}

struct WeatherTrigger {
    
    static var weatherOptions = [
        WeatherOptionInfo(title: WeatherOptionInfo.sunny, systemImage: "sun.min.fill"),
        WeatherOptionInfo(title: WeatherOptionInfo.cloudy, systemImage: "cloud.fill"),
        WeatherOptionInfo(title: WeatherOptionInfo.raining, systemImage:  "cloud.heavyrain.fill"),
        WeatherOptionInfo(title: WeatherOptionInfo.windy, systemImage: "wind.circle"),
        WeatherOptionInfo(title: WeatherOptionInfo.snowing, systemImage: "cloud.snow.fill"),
        WeatherOptionInfo(title: WeatherOptionInfo.thunder, systemImage: "cloud.bolt.rain")]
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
    
    var durationSelection : String
    var durationMeasurement : String
    var duration : Int
}

struct TimeFrame {
    var selection : String
    var timeRange : [Date]
    static var always = "Always"
    static var frame = "timeFrame"
}
