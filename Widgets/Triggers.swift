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

// START of Codable Time Frames
class TimeFrameInfo : Codable {
    var type : String
    
    init(type: String) {
        self.type = type
    }
    
    func printSelf() {
        print("type: \(type)")
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
    }
}

class HourTimeFrameInfo : TimeFrameInfo {
    var timeStart : Date
    var timeEnd : Date
    
    init(timeStart: Date, timeEnd: Date) {
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        super.init(type: TimeFrame.hour)
    }
    
    private enum CodingKeys: String, CodingKey {
        case timeStart
        case timeEnd
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeStart = try container.decode(Date.self, forKey: .timeStart)
        timeEnd = try container.decode(Date.self, forKey: .timeEnd)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.timeStart, forKey: .timeStart)
        try container.encode(self.timeEnd, forKey: .timeEnd)
    }
    
    override func printSelf() {
        super.printSelf()
        print("timeStart: \(timeStart.get(.hour)), timeEnd: \(timeEnd.get(.hour))")
    }
}

class WeekdayTimeFrameInfo : TimeFrameInfo {
    var timeStart : String
    var timeEnd : String
    
    init(timeStart: String, timeEnd: String) {
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        super.init(type: TimeFrame.dayOfTheWeek)
    }
    
    private enum CodingKeys: String, CodingKey {
        case timeStart
        case timeEnd
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeStart = try container.decode(String.self, forKey: .timeStart)
        timeEnd = try container.decode(String.self, forKey: .timeEnd)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.timeStart, forKey: .timeStart)
        try container.encode(self.timeEnd, forKey: .timeEnd)
    }
    
    override func printSelf() {
        super.printSelf()
        print("timeStart: \(timeStart), timeEnd: \(timeEnd)")
    }
}

class DateTimeFrameInfo : TimeFrameInfo {
    var timeStart : Int
    var timeEnd : Int
    
    init(timeStart: Int, timeEnd: Int) {
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        super.init(type: TimeFrame.dayOfTheMonth)
    }
    
    private enum CodingKeys: String, CodingKey {
        case timeStart
        case timeEnd
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeStart = try container.decode(Int.self, forKey: .timeStart)
        timeEnd = try container.decode(Int.self, forKey: .timeEnd)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.timeStart, forKey: .timeStart)
        try container.encode(self.timeEnd, forKey: .timeEnd)
    }
    
    override func printSelf() {
        super.printSelf()
        print("timeStart: \(timeStart), timeEnd: \(timeEnd)")
    }
}

class MonthTimeFrameInfo : TimeFrameInfo {
    var timeStart : String
    var timeEnd : String
    
    init(timeStart: String, timeEnd: String) {
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        super.init(type: TimeFrame.month)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.timeStart, forKey: .timeStart)
        try container.encode(self.timeEnd, forKey: .timeEnd)
    }
    
    private enum CodingKeys: String, CodingKey {
        case timeStart
        case timeEnd
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeStart = try container.decode(String.self, forKey: .timeStart)
        timeEnd = try container.decode(String.self, forKey: .timeEnd)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }
    
    override func printSelf() {
        super.printSelf()
        print("timeStart: \(timeStart), timeEnd: \(timeEnd)")
    }
}
// End of Codable Time Frames


// Start of Time Frame Observable objects
class TimeFrameState : ObservableObject {
    @Published var selected : Bool = false
    var type : String
    
    init(type: String) {
        self.type = type
    }
    
    func makeCodableInfo() -> TimeFrameInfo {
        return TimeFrameInfo(type: type)
    }
}

class HourTimeFrameState : TimeFrameState {
    @Published var timeStart : Date = Date()
    @Published var timeEnd  : Date = Date()
    
    init() {
        super.init(type: TimeFrame.hour)
    }
    
    override func makeCodableInfo() -> TimeFrameInfo {
        return HourTimeFrameInfo(timeStart: timeStart, timeEnd: timeEnd)
    }
}

class WeekdayTimeFrameState : TimeFrameState {
    @Published var timeStart : String = TimeFrame.weekdays[0]
    @Published var timeEnd  : String = TimeFrame.weekdays[0]
    
    init() {
        super.init(type: TimeFrame.dayOfTheWeek)
    }
    
    override func makeCodableInfo() -> TimeFrameInfo {
        return WeekdayTimeFrameInfo(timeStart: timeStart, timeEnd: timeEnd)
    }
}

class DateTimeFrameState : TimeFrameState {
    @Published var timeStart : Int = 0
    @Published var timeEnd : Int = 0
    
    init() {
        super.init(type: TimeFrame.dayOfTheMonth)
    }
    override func makeCodableInfo() -> TimeFrameInfo {
        return DateTimeFrameInfo(timeStart: timeStart, timeEnd: timeEnd)
    }
}

class MonthTimeFrameState : TimeFrameState {
    @Published var timeStart : String = TimeFrame.months[0]
    @Published var timeEnd : String = TimeFrame.months[0]
    
    init() {
        super.init(type: TimeFrame.month)
    }
    override func makeCodableInfo() -> TimeFrameInfo {
        return MonthTimeFrameInfo(timeStart: timeStart, timeEnd: timeEnd)
    }
}
// END of Time Frame Observable objects
