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
    
    static func none() -> String {
        return ""
    }
}

struct WeatherTrigger {
    
    static var sunny = "sunny"
    static var cloudy = "cloudy"
    static var raining = "raining"
    static var windy = "windy"
    static var snowing = "snowing"
    static var thunder = "thundering"
    
    static var weatherOptions = [
        WeatherOptionInfo(title: WeatherTrigger.sunny, systemImage: "sun.min.fill"),
        WeatherOptionInfo(title: WeatherTrigger.cloudy, systemImage: "cloud.fill"),
        WeatherOptionInfo(title: WeatherTrigger.raining, systemImage:  "cloud.heavyrain.fill"),
        WeatherOptionInfo(title: WeatherTrigger.windy, systemImage: "wind.circle"),
        WeatherOptionInfo(title: WeatherTrigger.snowing, systemImage: "cloud.snow.fill"),
        WeatherOptionInfo(title: WeatherTrigger.thunder, systemImage: "cloud.bolt.rain")]
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
    
    static func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.minute = minute
        dateComponents.hour = hour
        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        return userCalendar.date(from: dateComponents)!
    }
    
    static func eqDayMonthYear(year: Int, month: Int, day: Int) -> Bool {
        let curr = Date()
        return curr.get(.year) == year && curr.get(.month) == month && curr.get(.day) == day
    }
    
    static func timeIsGreaterThanNow(hour: Int, minute: Int) -> Bool {
        let curr = Date()
        return hour > curr.get(.hour) && minute > curr.get(.minute)
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
        let current = Date()
        print("hour time start: \(timeStart), hour time end: \(timeEnd)")
        return current.get(.hour) >= timeStart.get(.hour) && current.get(.hour) <= timeEnd.get(.hour)
              && current.get(.minute) >= timeStart.get(.minute) && current.get(.minute) <= timeEnd.get(.minute)
    }
    // Note: We do not just compare the dates here because this excludes second difference
    func startTimeIsBeforeNow() -> Bool {
        let current = Date()
        if timeStart.get(.hour) == current.get(.hour) {
            return timeStart.get(.minute) < current.get(.minute)
        } else {
            return timeStart.get(.hour) < current.get(.hour)
        }
    }
    // Note: We do not just compare the dates here because this excludes second difference
    func endTimeIsBeforeNow() -> Bool {
        let current = Date()
        if timeEnd.get(.hour) == current.get(.hour) {
            return timeEnd.get(.minute) < current.get(.minute)
        } else {
            return timeEnd.get(.hour) < current.get(.hour)
        }
    }
}

struct WeekdayTimeFrame : TimeFrameCodable {
    var selected : Bool = false
    var timeStart : String = TimeFrame.weekdays[0]
    var timeEnd : String = TimeFrame.weekdays[0]
    
    // how about from between saturday (7) and tuesday (3)
    // the range would be [7, 1, 2, 3] - split into two ranges
    // 7, 8, 9, 10
    // add 7 to the index and see if it falls into the range
    func nowWithinTimeRange() -> Bool {
        let now = Date()
        var startingIndex = TimeFrame.getWeekdayIndex(weekday: timeStart)
        var endingIndex = TimeFrame.getWeekdayIndex(weekday: timeEnd)
        let currentWeekday = now.get(.weekday)
        if startingIndex > endingIndex {
            let compareIndex = currentWeekday + 7
            let highEnd = startingIndex + endingIndex
            return compareIndex >= startingIndex && compareIndex <= highEnd
        } else {
            return currentWeekday >= startingIndex && currentWeekday <= endingIndex
        }
    }
    
    func getNextStartWeekday(afterDate: Date) -> Date {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.weekday = TimeFrame.getWeekdayIndex(weekday: timeStart)
        return cal.nextDate(after: afterDate, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
    }
    
    func getNextEndWeekday() -> Date {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.weekday = TimeFrame.getWeekdayIndex(weekday: timeEnd)
        return cal.nextDate(after: Date(), matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
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
    
    // Invariant: Will be called outside of range
    func getStartingTime() -> Date {
        var dateComponents = DateComponents()
        var startHour: Int; var startMinute: Int
        // if no hour specified, start in the beginning
        // if the start month is not specified, use current month
        let startMonth = Month == nil ? Date().get(.month) : TimeFrame.getMonthIndex(month: Month!.timeStart)
        // if the startMonth is less than the current month, increase year by 1
        let startYear = startMonth < Date().get(.month) ? Date().get(.year) + 1 : Date().get(.year)
        var startDate : Int
        if Hour == nil {
            startHour = 0
            startMinute = 0
        } else {
            startHour = Hour!.timeStart.get(.hour)
            startMinute = Hour!.timeStart.get(.minute)
        }
        if date == nil {
            // if the date isn't specified && it is the start month, then use today
            if startMonth == Date().get(.month) {
                startDate = Date().get(.day)
            } else {
                // if the date isn't specified && it is NOT the start month, then use 1
                startDate = 1
            }
        } else {
            startDate = date!.timeStart
        }
        // if weekday is null, the start day would already be set, otherwise, override
        if Weekday != nil {
            // make the date of the current start year, month, and date
            let current = Date()
            let potentialDate = TimeFrame.makeDate(year: startYear, month: startMonth,
                                                   day: startDate, hour: startHour,
                                                   minute: startMinute)
            let desiredWeekday = TimeFrame.getWeekdayIndex(weekday: Weekday!.timeStart)
            // only override if it is currently after time range, NOT before **OR** if weekdays don't match
            if current > potentialDate || potentialDate.get(.weekday) != desiredWeekday {
                let nextWeekdayDate = Weekday!.getNextStartWeekday(afterDate: potentialDate)
                startDate = nextWeekdayDate.get(.day)
            }
        }
        if Hour != nil && Hour!.startTimeIsBeforeNow() &&
            TimeFrame.eqDayMonthYear(year: startYear, month: startMonth, day: startDate) {
            startDate += 1
        }
        dateComponents.year = startYear
        dateComponents.month = startMonth
        dateComponents.day = startDate
        dateComponents.hour = startHour
        dateComponents.minute = startMinute
        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: dateComponents)!
    }
    
    // Invariant : Will be called inside of range, result date will always be in the future
    func getEndingTime() -> Date {
        var dateComponents = DateComponents()
        var endHour: Int; var endMinute: Int
        // if the start month is not specified, use current month
        let endMonth = Month == nil ? Date().get(.month) : TimeFrame.getMonthIndex(month: Month!.timeEnd)
        let endYear = endMonth < Date().get(.month) ? Date().get(.year) + 1 : Date().get(.year)
        // if the date isn't specified, use today
        var endDate : Int
        if Hour == nil {
            endHour = 24
            endMinute = 0
        } else {
            endHour = Hour!.timeEnd.get(.hour)
            endMinute = Hour!.timeEnd.get(.minute)
        }
        if date == nil {
            // if the date isn't specified && it is the end month, then use today
            if endMonth == Date().get(.month) {
                endDate = Date().get(.day)
            } else {
                // if the date isn't specified && it is NOT the end month, then use last day of month
                endDate = Date().endOfMonth(month: endMonth).get(.day)
            }
        } else {
            endDate = date!.timeEnd
        }
        if Weekday != nil {
            // make the date of the current start year, month, and date
            let potentialDate = TimeFrame.makeDate(year: endYear, month: endMonth,
                                                   day: endDate, hour: endHour,
                                                   minute: endMinute)
            let desiredWeekday = TimeFrame.getWeekdayIndex(weekday: Weekday!.timeEnd)
            // if weekday doesn't match
            if potentialDate.get(.weekday) != desiredWeekday {
                let nextWeekdayDate = Weekday!.getNextEndWeekday()
                // only override the date if the nextweekdate is before the end
                if date == nil || nextWeekdayDate <= potentialDate {
                    endDate = nextWeekdayDate.get(.day)
                }
            }
        }
        dateComponents.year = endYear
        dateComponents.month = endMonth
        dateComponents.day = endDate
        dateComponents.hour = endHour
        dateComponents.minute = endMinute + 1
        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: dateComponents)!
    }
    
}
