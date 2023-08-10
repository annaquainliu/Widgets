//
//  Triggers.swift
//  Widgets
//
//  Created by Anna Liu on 7/29/23.
//

import Foundation
import SwiftUI
import CoreLocation

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

class WeatherManager {
    private var apiKey = "4Q2MZ44JDQAXYD4G5EC34SUG6"
    var displayWidget : ((WidgetInfo) -> ())?
    var removeWidget : ((UUID) -> ())?
    
    init(displayWidget: ((WidgetInfo) -> ())? = nil, removeWidget: ((UUID) -> ())? = nil) {
        self.displayWidget = displayWidget
        self.removeWidget = removeWidget
    }
    
    func fetchWeather(location: CLLocation)  {
        let longitude = location.coordinate.longitude
        let latitude = location.coordinate.latitude
        let current = Date()
        let date = "\(current.get(.year))-\(current.get(.month))-\(current.get(.day))"
        let url = URL(string: "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(latitude),\(longitude)/\(date)?key=\(apiKey)")!
        print(url)
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                print(data)
                let decoded = try JSONDecoder().decode(WeatherApi.self, from: data)
                let currentConditions = decoded.currentConditions
                if currentConditions != nil {
                    print(currentConditions!)
                }
            } catch {
                print(String(describing: error))
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var lastKnownLocation: CLLocation?
    var weatherManager : WeatherManager?
    var startedUpdating : Bool = false
    
    func startUpdating() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        startedUpdating = true
        print(locations)
        lastKnownLocation = locations.last
        if weatherManager != nil {
            weatherManager?.fetchWeather(location: lastKnownLocation!)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorized {
            manager.startUpdatingLocation()
        }
    }
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
        let timeStartDate = TimeFrame.makeDate(year: current.get(.year), month: current.get(.month),
                                               day: current.get(.day), hour: timeStart.get(.hour),
                                               minute: timeStart.get(.minute))
        var timeEndDate = TimeFrame.makeDate(year: current.get(.year), month: current.get(.month),
                                             day: current.get(.day), hour: timeEnd.get(.hour),
                                             minute: timeEnd.get(.minute))
        if timeEndDate < timeStartDate {
            timeEndDate = Calendar.current.date(byAdding: .day, value: 1, to: timeEndDate)!
        }
        return (timeStartDate...timeEndDate).contains(current)
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
    
    func nowWithinTimeRange() -> Bool {
        let now = Date()
        let startingIndex = TimeFrame.getWeekdayIndex(weekday: timeStart)
        let endingIndex = TimeFrame.getWeekdayIndex(weekday: timeEnd)
        let currentWeekday = now.get(.weekday)
        if startingIndex > endingIndex {
            let firstRange = [startingIndex, 7]
            let secondRange = [1, endingIndex]
            return (currentWeekday >= firstRange[0] && currentWeekday <= firstRange[1]) ||
                   (currentWeekday >= secondRange[0] && currentWeekday <= secondRange[1])
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
        let currMonth = Date().get(.month)
        let monthStart = TimeFrame.getMonthIndex(month: timeStart)
        let monthEnd = TimeFrame.getMonthIndex(month: timeEnd)
        if monthStart > monthEnd {
            let firstRange = [monthStart, 12]
            let secondRange = [1, monthEnd]
            return (currMonth >= firstRange[0] && currMonth <= firstRange[1])
                || (currMonth >= secondRange[0] && currMonth <= secondRange[1])
        }
        else {
            return currMonth >= monthStart && currMonth <= monthEnd
        }
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
    // invariant for everything: EVERYTHING must repeat if selected!!
    
    // Invariant: Will be called outside of range (before or after)
    func getStartingTime() -> Date {
        let currentDate = Date()
        var dateComponents = DateComponents()
        var startHour: Int; var startMinute: Int; var startDate : Int; var startMonth: Int
        // if month is not specified
        if Month == nil {
            startMonth = currentDate.get(.month)
            if date == nil {
                startDate = currentDate.get(.day)
            }
            else {
                let currentDay = currentDate.get(.day)
                // if date is specified, check if the current day is after the date
                if currentDay > date!.timeEnd {
                    startMonth += 1 // increase month because it's after time range
                    startDate = date!.timeStart
                }
                else {
                    startDate = currentDay < date!.timeStart ? date!.timeStart : currentDay
                }
            }
        } else {
            // if month is specified
            let currMonth = currentDate.get(.month)
            if Month!.nowWithinTimeRange() {
                startMonth = currMonth
                // if the date is not specified, use current day, e
                if date == nil {
                    startDate = currentDate.get(.day)
                } else {
                    startDate = date!.nowWithinTimeRange() ? currentDate.get(.day) : date!.timeStart
                }
            }
            else { // if the month is not within time range
                startMonth = TimeFrame.getMonthIndex(month: Month!.timeStart)
                startDate = date == nil ? 1 : date!.timeStart
            }
        }
        // if the startMonth is less than the current month, increase year by 1
        let startYear = startMonth < currentDate.get(.month) ? currentDate.get(.year) + 1 : currentDate.get(.year)
        if Hour == nil {
            startHour = 0
            startMinute = 0
        } else {
            startHour = Hour!.timeStart.get(.hour)
            startMinute = Hour!.timeStart.get(.minute)
        }
        // if weekday is null, the start day would already be set, otherwise, override
        if Weekday != nil {
            let current = currentDate
            // make the date of the current start year, month, and date
            let potentialDate = TimeFrame.makeDate(year: startYear, month: startMonth,
                                                   day: startDate, hour: startHour,
                                                   minute: startMinute)
            // if it is out of range
            if (current > potentialDate &&
                current.get(.weekday) == TimeFrame.getWeekdayIndex(weekday: Weekday!.timeEnd))
                || !Weekday!.nowWithinTimeRange() {
                
                let nextWeekdayDate = Weekday!.getNextStartWeekday(afterDate: potentialDate)
                // Note: The start date might be outside the time range,
                // but the timer verification takes care of this
                startDate = nextWeekdayDate.get(.day)
            }
        }
        let futureDate = TimeFrame.makeDate(year: startYear, month: startMonth,
                                               day: startDate, hour: startHour,
                                               minute: startMinute)
        // if the future date is in the past, it is referring to tomorrow
        if futureDate < currentDate {
            startDate += 1
        }
        dateComponents.year = startYear
        dateComponents.month = startMonth
        dateComponents.day = startDate
        dateComponents.hour = startHour
        dateComponents.minute = startMinute
        print("starting UTC date is: \(startMonth)/\(startDate)/\(startYear), Time: \(startHour):\(startMinute)")
        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: dateComponents)!
    }
    
    // Invariant : Will be called inside of range, result date will always be in the future
    func getEndingTime() -> Date {
        let currentDate = Date()
        var dateComponents = DateComponents()
        var endHour: Int; var endMinute: Int; var endDate : Int; var endMonth: Int
        // if the start month is not specified, use current month
        if Month == nil {
            endMonth = currentDate.get(.month)
        } else {
            if Month!.nowWithinTimeRange() {
                endMonth = currentDate.get(.month)
            } else {
                endMonth = TimeFrame.getMonthIndex(month: Month!.timeEnd)
            }
        }
        let endYear = endMonth < currentDate.get(.month) ? currentDate.get(.year) + 1 : currentDate.get(.year)
        // if hour is specified, day must repeat
        if Hour == nil {
            endHour = 23
            endMinute = 59
            endDate = date == nil ? currentDate.endOfMonth(month: endMonth).get(.day) : date!.timeEnd
            if Weekday != nil {
                // make the date of the current start year, month, and date
                let potentialDate = TimeFrame.makeDate(year: endYear, month: endMonth,
                                                       day: endDate, hour: endHour,
                                                       minute: endMinute)
                let desiredWeekday = TimeFrame.getWeekdayIndex(weekday: Weekday!.timeEnd)
                var nextWeekdayDate = Weekday!.getNextEndWeekday()
                // to make sure if the next weekend actually refers to today
                if currentDate.get(.weekday) == desiredWeekday {
                    nextWeekdayDate = currentDate
                }
                print("next weekday date is: \(nextWeekdayDate)")
                // only override the date if the nextweekdate is before the end
                if (date == nil && nextWeekdayDate.get(.month) <= endMonth)
                    || nextWeekdayDate <= potentialDate {
                    endDate = nextWeekdayDate.get(.day)
                }
                
            }
        } else {
            endHour = Hour!.timeEnd.get(.hour)
            endMinute = Hour!.timeEnd.get(.minute)
            endDate = currentDate.get(.day)
        }
        let futureDate = TimeFrame.makeDate(year: endYear, month: endMonth,
                                               day: endDate, hour: endHour,
                                               minute: endMinute)
        // if the future date is in the past, it is referring to tomorrow
        if futureDate < currentDate {
            endDate += 1
        }
        dateComponents.year = endYear
        dateComponents.month = endMonth
        dateComponents.day = endDate
        dateComponents.hour = endHour
        dateComponents.minute = endMinute + 1
        print("ending UTC date is: \(endMonth)/\(endDate)/\(endYear), Time: \(endHour):\(endMinute + 1)")
        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: dateComponents)!
    }
    
}
