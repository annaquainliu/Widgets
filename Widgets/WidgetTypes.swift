//
//  Triggers.swift
//  Widgets
//
//  Created by Anna Liu on 7/29/23.
//

import Foundation
import SwiftUI
import CoreLocation
import Quartz



// class that stores information for all widgets
class WidgetInfo : Codable, Hashable {
    static func == (lhs: WidgetInfo, rhs: WidgetInfo) -> Bool {
        return lhs.getID() == rhs.getID()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(info.type)
        hasher.combine(trigger.type)
    }
    
    var info : WidgetTypeInfo
    var trigger : Triggers
    var xCoord : Double = 0
    var yCoord : Double = 0 
    var widgetSize : NSSize = NSSize()
    var slideshow : SlideshowInfo
    var imageURLs : [URL]
    private var id : UUID;
    
    init(info: WidgetTypeInfo, trigger : Triggers, imageURLs: [URL], slideshow : SlideshowInfo, id: UUID? = nil)  {
        self.info = info;
        self.imageURLs = imageURLs
        self.trigger = trigger
        self.slideshow = slideshow
        if (id == nil) {
            self.id = UUID();
        }
        else {
            self.id = id!;
        }
    }
    
    func initCoordsAndSize(xCoord : Double, yCoord : Double, size : NSSize) {
        self.xCoord = xCoord
        self.yCoord = yCoord
        self.widgetSize = size
    }
    
    func getID() -> UUID {
        return self.id
    }
    
    enum CodingKeys: String, CodingKey {
        case info, trigger, xCoord, yCoord, widgetSize, slideshow, imageURLs, id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let infoValue = try values.nestedContainer(keyedBy: WidgetTypeInfo.CodingKeys.self,
                                                    forKey: .info)
        let infoType = try infoValue.decode(WidgetTypeInfo.types.self, forKey: WidgetTypeInfo.CodingKeys.type)
        switch infoType {
            case WidgetTypeInfo.types.image:
                self.info = try values.decode(WidgetTypeInfo.self, forKey: .info)
            case WidgetTypeInfo.types.text:
                self.info = try values.decode(TextWidgetInfo.self, forKey: .info)
            case WidgetTypeInfo.types.calendar:
                self.info = try values.decode(CalendarInfo.self, forKey: .info)
            case WidgetTypeInfo.types.countdown:
                self.info = try values.decode(CountDownWidgetInfo.self, forKey: .info)
            default:
                self.info = try values.decode(ScreenWidgetInfo.self, forKey: .info)
        }
        let triggerValue = try values.nestedContainer(keyedBy: Triggers.CodingKeys.self, forKey: .trigger)
        let triggerType = try triggerValue.decode(Triggers.types.self, forKey: Triggers.CodingKeys.type)
        switch triggerType {
            case Triggers.types.always:
                self.trigger = try values.decode(Triggers.self, forKey: .trigger)
            case Triggers.types.staticTimeFrame:
                self.trigger = try values.decode(StaticTimeFrame.self, forKey: .trigger)
            case Triggers.types.timeFrame:
                self.trigger = try values.decode(TimeFrameInfo.self, forKey: .trigger)
            default:
                self.trigger = try values.decode(WeatherTrigger.self, forKey: .trigger)
        }
        self.xCoord = try values.decode(Double.self, forKey: .xCoord)
        self.yCoord = try values.decode(Double.self, forKey: .yCoord)
        self.widgetSize = try values.decode(NSSize.self, forKey: .widgetSize)
        self.slideshow = try values.decode(SlideshowInfo.self, forKey: .slideshow)
        self.imageURLs = try values.decode([URL].self, forKey: .imageURLs)
        self.id = try values.decode(UUID.self, forKey: .id)
    }
    
    
}


struct SlideshowInfo : Codable {
    var interval : Int
}

class WidgetTypeInfo : Codable, ObservableObject {
    
    var type : WidgetTypeInfo.types
    
    enum types : Int, Codable {
        case image, calendar, desktop, text, countdown
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    init(type: WidgetTypeInfo.types) {
        self.type = type
    }

}

class CalendarInfo : WidgetTypeInfo {
    
    @Published var calendarType : CalendarSizes.types
    
    enum CodingKeys: String, CodingKey {
        case calendarType
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.calendarType = try values.decode(CalendarSizes.types.self, forKey: .calendarType)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.calendarType, forKey: .calendarType)
        try super.encode(to: encoder)
    }

    init(calendarType : CalendarSizes.types) {
        self.calendarType = calendarType
        super.init(type: WidgetTypeInfo.types.calendar)
    }
    
}

class CountDownWidgetInfo : WidgetTypeInfo {
    @Published var time : Date
    @Published var desc : String
    
    init(time: Date, desc: String) {
        self.time = time
        self.desc = desc
        super.init(type: WidgetTypeInfo.types.countdown)
    }
    
    enum CodingKeys: String, CodingKey {
        case time, desc
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.time = try values.decode(Date.self, forKey: .time)
        self.desc = try values.decode(String.self, forKey: .desc)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.time, forKey: .time)
        try container.encode(self.desc, forKey: .desc)
        try super.encode(to: encoder)
    }
    
}

class TextWidgetInfo : WidgetTypeInfo {
    
    @Published var text : String
    @Published var font : String
    
    init(text: String, font: String) {
        self.text = text
        self.font = font
        super.init(type: WidgetTypeInfo.types.text)
    }
    
    enum CodingKeys: String, CodingKey {
        case text, font
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try values.decode(String.self, forKey: .text)
        self.font = try values.decode(String.self, forKey: .font)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.font, forKey: .font)
        try super.encode(to: encoder)
    }
    

}

class ScreenWidgetInfo : WidgetTypeInfo {
    
    @Published var opacity : Float
    
    init(opacity: Float) {
        self.opacity = opacity
        super.init(type: WidgetTypeInfo.types.desktop)
    }
    
    enum CodingKeys: String, CodingKey {
        case opacity
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.opacity = try values.decode(Float.self, forKey: .opacity)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.opacity, forKey: .opacity)
        try super.encode(to: encoder)
    }
}

class Triggers : Codable {
    
    var type : Triggers.types
    
    enum types : String, Codable {
        case always = "Always"
        case weather = "Weather"
        case timeFrame = "timeFrame"
        case staticTimeFrame = "staticTimeFrame"
    }
    
    init(type: Triggers.types) {
        self.type = type
    }
    
    func stringifyTrigger() -> String {
        return "Always"
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .type)
    }
    
}

struct WeatherOptionInfo : Hashable {
    var title : WeatherTrigger.types;
    var systemImage : String;
    
    static func none() -> String {
        return ""
    }
}

// specific Weather information
class WeatherTrigger : Triggers {

    var weather : WeatherTrigger.types
    
    enum types : String, Codable {
        case sunny, cloudy, raining, windy, snowing, thunder
    }
    
    static var weatherOptions = [
        WeatherOptionInfo(title: WeatherTrigger.types.sunny, systemImage: "sun.min.fill"),
        WeatherOptionInfo(title: WeatherTrigger.types.cloudy, systemImage: "cloud.fill"),
        WeatherOptionInfo(title: WeatherTrigger.types.raining, systemImage:  "cloud.heavyrain.fill"),
        WeatherOptionInfo(title: WeatherTrigger.types.windy, systemImage: "wind.circle"),
        WeatherOptionInfo(title: WeatherTrigger.types.snowing, systemImage: "cloud.snow.fill"),
        WeatherOptionInfo(title: WeatherTrigger.types.thunder, systemImage: "cloud.bolt.rain")]
    
    init(weather: WeatherTrigger.types) {
        self.weather = weather
        super.init(type: Triggers.types.weather)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.weather = try values.decode(WeatherTrigger.types.self, forKey: .weather)
        try super.init(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case weather
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.weather, forKey: .weather)
    }
    
    override func stringifyTrigger() -> String {
        return "When it is \(self.weather.rawValue)"
    }

}

class WeatherManager {
    static var apiKey = "4Q2MZ44JDQAXYD4G5EC34SUG6"
    static var currentConditions : CurrentConditions? = nil
    
    static func fetchWeather() async {
        print("fetching weather")
        if LocationManager.lastKnownLocation == nil {
            print("location manager last known location is null")
            return
        }
        let location = LocationManager.lastKnownLocation!
        let longitude = location.coordinate.longitude
        let latitude = location.coordinate.latitude
        let current = Date()
        let date = "\(current.get(.year))-\(current.get(.month))-\(current.get(.day))"
        let url = URL(string: "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(latitude),\(longitude)/\(date)?key=\(apiKey)")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(WeatherApi.self, from: data)
            let currentConditions = decoded.currentConditions
            WeatherManager.currentConditions = currentConditions
            print(currentConditions as Any)
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    static func shouldWidgetBeOn(widget: WidgetInfo) -> Bool {
        if WeatherManager.currentConditions == nil {
            print("called shouldWidgetBeOn when current conditions is nil error")
            return false
        }
        let trigger = widget.trigger as! WeatherTrigger
        let weatherType = trigger.weather
        if WeatherManager.currentConditions!.precipprob > 0.2 {
            if weatherType == WeatherTrigger.types.snowing {
                return WeatherManager.currentConditions?.preciptype == "snow"
            }
            else if weatherType == WeatherTrigger.types.raining {
                return WeatherManager.currentConditions?.preciptype == "rain"
            }
        }
        switch weatherType {
            case WeatherTrigger.types.cloudy:
                return WeatherManager.currentConditions!.cloudcover > 0.4
            case WeatherTrigger.types.windy:
                return WeatherManager.currentConditions!.windspeed > 20
            case WeatherTrigger.types.sunny:
                return WeatherManager.currentConditions!.solarradiation > 600
            default:
                return false
        }
    }
    
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    static var lastKnownLocation: CLLocation? = nil
    var displayDesktopWidgets : DisplayDesktopWidgets?
    
    func startUpdating() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        LocationManager.lastKnownLocation = locations.last
        displayDesktopWidgets?.loadWidgets()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorized {
            manager.startUpdatingLocation()
        } else {
            displayDesktopWidgets?.loadWidgets()
        }
    }
}

class StaticTimeFrame : Triggers, ObservableObject {
    @Published var timeStart : Date
    @Published var timeEnd : Date
    
    override func stringifyTrigger() -> String {
        return "Start Time: \(timeStart), End Time: \(timeEnd) \n";
    }
    
    init(timeStart: Date, timeEnd: Date) {
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        super.init(type: Triggers.types.staticTimeFrame)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.timeStart = try values.decode(Date.self, forKey: .timeStart)
        self.timeEnd = try values.decode(Date.self, forKey: .timeEnd)
        try super.init(from: decoder)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case timeStart
        case timeEnd
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.timeStart, forKey: .timeStart)
        try container.encode(self.timeEnd, forKey: .timeEnd)
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
    
    static func makeDate(year: Int, month: Int, day: Int, hour: Int? = nil, minute: Int? = nil) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.minute = minute == nil ? 0 : minute
        dateComponents.hour = hour == nil ? 0 : hour
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
    func stringify() -> String

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
        timeEndDate = Calendar.current.date(byAdding: .minute, value: 1, to: timeEndDate)!
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
    
    func stringify() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let startFormatted = dateFormatter.string(from: timeStart)
        let endFormatted = dateFormatter.string(from: timeEnd)
        return "Start Time: \(startFormatted), End Time: \(endFormatted)\n"
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
    
    func stringify() -> String {
        return "Start Day: \(timeStart), End Day: \(timeEnd) \n"
    }
}

struct DateTimeFrame : TimeFrameCodable {
    var selected : Bool = false
    var timeStart : Int = 0
    var timeEnd : Int = 0
    
    func nowWithinTimeRange() -> Bool {
        return Date().get(.day) >= timeStart + 1 && Date().get(.day) <= timeEnd + 1
    }
    
    func getTimeStart() -> Int {
        return timeStart + 1
    }
    
    func getTimeEnd() -> Int {
        return timeEnd + 1
    }
    
    func stringify() -> String {
        return "Date Start: \(timeStart), Date End: \(timeEnd) \n"
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
    
    func stringify() -> String {
        return "Month Start: \(timeStart), Month End: \(timeEnd) \n"
    }
}

class TimeFrameInfo : Triggers {
    var Hour : HourTimeFrame?
    var Weekday : WeekdayTimeFrame?
    var date : DateTimeFrame?
    var Month : MonthTimeFrame?
    
    init(Hour: HourTimeFrame? = nil, Weekday: WeekdayTimeFrame? = nil, Date: DateTimeFrame? = nil, Month: MonthTimeFrame? = nil) {
        super.init(type: Triggers.types.timeFrame)
        self.Hour = Hour
        self.Weekday = Weekday
        self.date = Date
        self.Month = Month
    }
    
    enum CodingKeys: String, CodingKey {
        case Hour
        case Weekday
        case date
        case Month
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.Hour, forKey: .Hour)
        try container.encode(self.Weekday, forKey: .Weekday)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.Month, forKey: .Month)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Hour = try values.decode(HourTimeFrame?.self, forKey: .Hour)
        self.Weekday = try values.decode(WeekdayTimeFrame?.self, forKey: .Weekday)
        self.date = try values.decode(DateTimeFrame?.self, forKey: .date)
        self.Month = try values.decode(MonthTimeFrame?.self, forKey: .Month)
    }
    
    override func stringifyTrigger() -> String {
        let timeFrames : [TimeFrameCodable?] = [Hour, Weekday, date, Month]
        var result = ""
        for i in 0..<timeFrames.count {
            if timeFrames[i] != nil {
                result += timeFrames[i]!.stringify()
            }
        }
        return result
    }
    
    // Invariant: Will be called outside of range (before or after)
    func getStartingTime() -> Date {
        let currentDate = Date()
        var dateComponents = DateComponents()
        var startHour: Int; var startMinute: Int; var startDate : Int; var startMonth: Int
        if Hour == nil {
            startHour = 0
            startMinute = 0
        } else {
            startHour = Hour!.timeStart.get(.hour)
            startMinute = Hour!.timeStart.get(.minute)
        }
        // if month is not specified
        if Month == nil {
            startMonth = currentDate.get(.month)
            if date == nil {
                startDate = currentDate.get(.day)
            }
            else {
                let currentDay = currentDate.get(.day)
                let potentialDate = TimeFrame.makeDate(year: currentDate.get(.year), month: startMonth,
                                                       day: date!.getTimeEnd(), hour: startHour,
                                                       minute: startMinute)
                // if date is specified, check if the current day is after the date
                if currentDate > potentialDate {
                    startMonth += 1 // increase month because it's after time range
                    startDate = date!.getTimeStart()
                }
                else {
                    startDate = currentDay < date!.getTimeStart() ? date!.getTimeStart() : currentDay
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
                    startDate = date!.nowWithinTimeRange() ? currentDate.get(.day) : date!.getTimeStart()
                }
            }
            else { // if the month is not within time range
                startMonth = TimeFrame.getMonthIndex(month: Month!.timeStart)
                startDate = date == nil ? 1 : date!.getTimeStart()
            }
        }
        // if the startMonth is less than the current month, increase year by 1
        let startYear = startMonth < currentDate.get(.month) ? currentDate.get(.year) + 1 : currentDate.get(.year)
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
        var endHour: Int; var endMinute: Int; var endDate : Int; var endMonth: Int; var endYear: Int
        // if hour is specified, day must repeat
        if Hour == nil {
            endHour = 23
            endMinute = 59
            endMonth = Month == nil ? currentDate.get(.month) : TimeFrame.getMonthIndex(month: Month!.timeEnd)
            endYear = endMonth < currentDate.get(.month) ? currentDate.get(.year) + 1 : currentDate.get(.year)
            endDate = date == nil ? currentDate.endOfMonth(month: endMonth).get(.day) : date!.getTimeEnd()
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
            endMonth = currentDate.get(.month)
            endYear = currentDate.get(.year)
            endHour = Hour!.timeEnd.get(.hour)
            endMinute = Hour!.timeEnd.get(.minute)
            endDate = currentDate.get(.day)
        }
        endMinute += 1 //add 1 to make the end time be the end of the minute
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
        dateComponents.minute = endMinute
        print("ending UTC date is: \(endMonth)/\(endDate)/\(endYear), Time: \(endHour):\(endMinute)")
        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: dateComponents)!
    }
    
}

/** END OF WIDGET TRIGGERS! */

/** START  OF WIDGET  TYPES! */

struct CalendarSizes  {
    static var calWidth = 156.5 * CalendarSizes.scale
    static var calHeight = 168.0 * CalendarSizes.scale
    static var clockWidth = 140 * CalendarSizes.scale
    static var clockHeight = 140 * CalendarSizes.scale
    static var alarmWidth = 400.0
    static var alarmHeight = 110.0
    static var scale = 1.5
    
    enum types : Int, Codable {
        case calendar, clock, text
    }
    
    static func makeCalendarSize(type: CalendarSizes.types) -> NSSize {
        switch type {
            case CalendarSizes.types.calendar:
                return NSSize(width: calWidth, height: calHeight)
            case CalendarSizes.types.clock:
                return NSSize(width: clockWidth, height: clockHeight)
            default:
                return NSSize(width: alarmWidth, height: alarmHeight)
        }
    }
}


struct CalendarIcon : View {
 
    var body: some View {
        TimelineView(.periodic(from: TimeFrame.makeDate(year: Date().get(.year), month: Date().get(.month), day: Date().get(.day) + 1) , by: 86400)) { context in
            DatePicker("", selection: .constant(Date()), displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .scaleEffect(CalendarSizes.scale, anchor: .leading)
                .frame(width: CalendarSizes.calWidth, height: CalendarSizes.calHeight)
                .accentColor(.white)
        }
    }
}

struct ClockIcon : View {
    
    var body: some View {
        TimelineView(.everyMinute) {context  in
            DatePicker("", selection: .constant(context.date), displayedComponents: [.hourAndMinute])
            .datePickerStyle(.graphical)
            .scaleEffect(CalendarSizes.scale, anchor: .leading)
            .accentColor(.white)
            .frame(width: CalendarSizes.clockWidth, height: CalendarSizes.clockHeight)
        }
    }
}

struct AlarmIcon : View {
    
    var body: some View {
        TimelineView(.everyMinute) {context  in
            Text(context.date.formatted(.dateTime).split(separator: ",")[1] + " ")
                .font(.custom("Arial", size: 70))
                .frame(width: CalendarSizes.alarmWidth, height: CalendarSizes.alarmHeight)
        }
    }
}

struct Countdown : View {
    
    var end : Date
    var corderRadius : CGFloat = 3
    var desc : String
    var largeFont : CGFloat = 30 * Countdown.scale
    var smallFont : CGFloat = 11 * Countdown.scale
    var descFont : CGFloat = 20 * Countdown.scale
    static var width : CGFloat = 220 * Countdown.scale
    static var height : CGFloat = 95 * Countdown.scale
    static var scale = 1.5
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let diff = Calendar.current.dateComponents([.hour, .day, .minute, .second], from: timeline.date, to: end)
            VStack {
                HStack {
                    VStack {
                        Text("\(diff.day!)").font(.system(size: largeFont, weight: .thin))
                        Text("Day").font(.system(size: smallFont, weight: .thin))
                    }
                    Text(":").font(Font.custom("Arial", size: largeFont))
                    VStack {
                        Text("\(diff.hour!)").font(.system(size: largeFont, weight: .thin))
                        Text("Hour").font(.system(size: smallFont, weight: .thin))
                    }
                    Text(":").font(Font.custom("Arial", size: largeFont))
                    VStack {
                        Text("\(diff.minute!)").font(.system(size: largeFont, weight: .thin))
                        Text("Minute").font(.system(size: smallFont, weight: .thin))
                    }
                    Text(":").font(Font.custom("Arial", size: largeFont))
                    VStack {
                        Text("\(diff.second!)").font(.system(size: largeFont, weight: .thin))
                        Text("Second").font(.system(size: smallFont, weight: .thin))
                    }
                }
                Text(desc).font(.custom("Brush Script MT", size: descFont))
            }.frame(width: Countdown.width, height: Countdown.height)
        }
    }

}

struct TextLayerView: View {
    var size: NSSize
    var info : TextWidgetInfo
    var body: some View {
        Text(info.text)
            .font(.custom(info.font, size: 20))
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .frame(maxWidth: size.width, maxHeight: size.height)
    }
}
//
//struct TextLayerView_Providers: PreviewProvider {
//    static var previews: some View {
//        TextLayerView(size: NSSize(width: 300, height: 300), info: TextInfo(text: "SDHFSJDFSDJFDISJFBDSIJFBDSIFIJSBFJSBJFSKJFBSKBDF", font: "Arial"))
//    }
//}


//struct Countdown_Providers: PreviewProvider {
//    static var previews: some View {
//        Countdown(end: TimeFrame.makeDate(year: 2023, month: 10, day: 31), desc: "Until Halloween!")
//    }
//}

//struct AlarmIcon_Providers: PreviewProvider {
//    static var previews: some View {
//        AlarmIcon()
//    }
//}


//struct CalendarView_Providers: PreviewProvider {
//    static var previews: some View {
//        CalendarIcon()
//    }
//}

//struct ClockView_Providers: PreviewProvider {
//    static var previews: some View {
//        ClockIcon()
//    }
//}

