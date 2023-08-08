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
    static var weekdays = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    static func getMonthIndex(month: String) -> Int {
        return TimeFrame.months.firstIndex(of: month)! + 1
    }
    
    static func getWeekdayIndex(weekday: String) -> Int {
        return TimeFrame.weekdays.firstIndex(of: weekday)! + 1
    }
}

protocol TimeFrameCodable : Codable {
    func nowWithinTimeRange() -> Bool
}

struct HourTimeFrame : TimeFrameCodable {
    var selected : Bool = false
    var timeStart : Date = Date.now
    var timeEnd : Date = Date.now
    
    func nowWithinTimeRange() -> Bool {
        return Date().get(.hour) >= timeStart.get(.hour) && Date().get(.hour) <= timeEnd.get(.hour)
              && Date().get(.minute) >= timeStart.get(.minute)  && Date().get(.minute) <= timeEnd.get(.minute)
    }
}

struct WeekdayTimeFrame : TimeFrameCodable {
    var selected : Bool = false
    var timeStart : String = TimeFrame.weekdays[0]
    var timeEnd : String = TimeFrame.weekdays[0]
    
    func nowWithinTimeRange() -> Bool {
        return Date().get(.weekday) >= TimeFrame.getWeekdayIndex(weekday: timeStart)
            && Date().get(.weekday) <= TimeFrame.getWeekdayIndex(weekday: timeEnd)
    }
    
    func getNextWeekday(afterDate: Date) -> Date {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.weekday = TimeFrame.getWeekdayIndex(weekday: timeStart)
        return cal.nextDate(after: afterDate, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
    }
}

struct DateTimeFrame : TimeFrameCodable {
    var selected : Bool = false
    var timeStart : Int = 0
    var timeEnd : Int = 0
    
    func nowWithinTimeRange() -> Bool {
        return Date().get(.day) >= timeStart + 1 && Date().get(.day) <= timeEnd + 1
    }
}

struct MonthTimeFrame : TimeFrameCodable {
    var selected : Bool = false
    var timeStart : String = TimeFrame.months[0]
    var timeEnd : String = TimeFrame.months[0]
    
    func nowWithinTimeRange() -> Bool {
        return Date().get(.month) >= TimeFrame.getMonthIndex(month: timeStart)
             && Date().get(.month) <= TimeFrame.getMonthIndex(month: timeEnd)
    }
    
    func getStartingTime() -> Date {
        return MonthTimeFrame.getStartingMonth(month: TimeFrame.getMonthIndex(month: timeStart))
    }
    
    static func getStartingMonth(month: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: Date().get(.year),
                                                      month: month,
                                                      day: 1))!
        return date
    }
    
}

struct TimeFrameInfo : Codable {
    var Hour : HourTimeFrame?
    var Weekday : WeekdayTimeFrame?
    var date : DateTimeFrame?
    var Month : MonthTimeFrame?
    
    init(Hour: HourTimeFrame? = nil, Weekday: WeekdayTimeFrame? = nil, Date: DateTimeFrame? = nil, Month: MonthTimeFrame? = nil) {
        self.Hour = Hour
        self.Weekday = Weekday
        self.date = Date
        self.Month = Month
    }
    
    // will always be called when it is currently before the starting time
    func getStartingTime() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = Date().get(.year)
        if Hour == nil {
            dateComponents.hour = 1
            dateComponents.minute = 0
        } else {
            dateComponents.hour = Hour?.timeStart.get(.hour)
            dateComponents.minute = Hour?.timeStart.get(.minute)
        }
        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: dateComponents)!
    }
    
    func getMonthAndDay() -> [String : Int] {
        // if no month is specified, use current month
        var month = Month == nil ? Date().get(.month) : TimeFrame.getMonthIndex(month: Month!.timeStart)
        let monthDate = MonthTimeFrame.getStartingMonth(month: month)
        var dayOfMonth : Int = 0
        if Weekday == nil && self.date == nil { // if no day/weekday specified, use current day
            dayOfMonth = Date().get(.day)
        }
        else if self.date == nil {
            // if only weekday specified, find the nearest date
            let nextweekday = Weekday!.getNextWeekday(afterDate: monthDate)
            // incase the nextweekday rolls over, use its new month and day
            month = nextweekday.get(.month)
            dayOfMonth = nextweekday.get(.day)
        }
        else if self.Weekday == nil { // if only date is specified
            dayOfMonth = self.date!.timeStart
        }
        else { // both are available - find earliest date
            let day = self.date!.timeStart
            let nextweekday = Weekday!.getNextWeekday(afterDate: monthDate)
            // if the next weekday rolls over to the next month, set the day to be the specified date
            if nextweekday.get(.month) > month {
                dayOfMonth = day
            } else {
                // if the next weekday is at the same month of the date, fin the earliest day
                dayOfMonth = day < nextweekday.get(.day) ? day : nextweekday.get(.day)
            }
        }
        return ["month": month, "day": dayOfMonth]
    }
    
//    func getEndingTime() -> Date {
//        var dateComponents = DateComponents()
//        if Hour == nil {
//            dateComponents.hour = 23
//            dateComponents.minute = 59
//        } else {
//            dateComponents.hour = Hour?.timeStart.get(.hour)
//            dateComponents.minute = Hour?.timeStart.get(.minute)
//        }
//
//    }
}
