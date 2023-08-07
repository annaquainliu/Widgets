//
//  Triggers.swift
//  Widgets
//
//  Created by Anna Liu on 7/29/23.
//

import Foundation
import SwiftUI

struct WeatherOptionInfo : Hashable {
    var title : String;
    var systemImage : String;
    static var sunny = "sunny"
    static var cloudy = "cloudy"
    static var raining = "raining"
    static var windy = "windy"
    static var snowing = "snowing"
    static var thunder = "thundering"
    
    static func none() -> String {
        return ""
    }
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
    static var loc = "Location"
    static var timeFrame = "TimeFrame"
    
    static func triggerDescription() -> some View {
        return HStack {
            Text("Triggers").font(.title).padding()
            Text("*When should the widget be visible?*").font(.title3)
        }
    }
}

struct Frequency : Codable {
    var measurement : String
    var frequency : Int
    var startDate : Date
    
    static func none() -> Frequency {
        return Frequency(measurement: "", frequency: 0, startDate: Date())
    }
}

struct Duration : Codable {
    static var untilDeactivate = "UntilDeactivated"
    static var duration  = "duration"
    
    var durationSelection : String
    var durationMeasurement : String
    var duration : Int
    
    static func none() -> Duration {
        return Duration(durationSelection: "", durationMeasurement: "", duration: 0)
    }
}

struct TimeFrame {
    static var hour = "hour" // e.g. between 3pm and 6pm, option to repeat every day
    static var dayOfTheWeek = "day" // e.g .monday - tuesday, option to repeat every week
    static var dayOfTheMonth = "date" // e.g. 23rd-25th, option to repeat every month
    static var month = "month" // e.g. between november and december, option to repeat every year
    static var measurements : [String] = [TimeFrame.hour, TimeFrame.dayOfTheWeek, TimeFrame.dayOfTheMonth, TimeFrame.month]
    static var months = ["January", "Feburary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    static var weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    static func getMonthIndex(month: String) -> Int {
        return TimeFrame.months.firstIndex(of: month)! + 1
    }
    
    static func getWeekdayIndex(weekday: String) -> Int {
        return TimeFrame.weekdays.firstIndex(of: weekday)! + 1
    }
}

struct HourTimeFrame : Codable {
    var selected : Bool = false
    var timeStart : Date = Date.now
    var timeEnd : Date = Date.now
}

struct WeekdayTimeFrame : Codable {
    var selected : Bool = false
    var timeStart : String = TimeFrame.weekdays[0]
    var timeEnd : String = TimeFrame.weekdays[0]
}

struct DateTimeFrame : Codable {
    var selected : Bool = false
    var timeStart : Int = 0
    var timeEnd : Int = 0
}

struct MonthTimeFrame : Codable {
    var selected : Bool = false
    var timeStart : String = TimeFrame.months[0]
    var timeEnd : String = TimeFrame.months[0]
}

struct TimeFrameInfo : Codable {
    var Hour : HourTimeFrame?
    var Weekday : WeekdayTimeFrame?
    var Date : DateTimeFrame?
    var Month : MonthTimeFrame?
    
    init(Hour: HourTimeFrame? = nil, Weekday: WeekdayTimeFrame? = nil, Date: DateTimeFrame? = nil, Month: MonthTimeFrame? = nil) {
        self.Hour = Hour
        self.Weekday = Weekday
        self.Date = Date
        self.Month = Month
    }
//
//    func nowWithinTimeRange() -> Bool {
//        switch type {
//            case TimeFrame.hour:
//                return Date().get(.hour) >= dateTimeStart.get(.hour) && Date().get(.hour) <= dateTimeEnd.get(.hour)
//            case TimeFrame.dayOfTheWeek:
//                return Date().get(.weekday) >= TimeFrame.getWeekdayIndex(weekday: stringTimeStart)
//                        && Date().get(.weekday) <= TimeFrame.getWeekdayIndex(weekday: stringTimeEnd)
//            case TimeFrame.dayOfTheMonth:
//                return Date().get(.day) >= intTimeStart && Date().get(.day) <= intTimeEnd
//            default:
//                return Date().get(.month) >= TimeFrame.getMonthIndex(month: stringTimeStart)
//                && Date().get(.month) <= TimeFrame.getMonthIndex(month: stringTimeEnd)
//        }
//    }
    
}
