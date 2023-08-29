//
//  WeatherAPI.swift
//  Widgets
//
//  Created by Anna Liu on 8/10/23.
//

import Foundation

struct WeatherApi : Codable {
     var queryCost: Int?
     var latitude: Double?
     var longitude: Double?
     var resolvedAddress: String?
     var address: String?
     var timezone: String?
     var tzoffset: Double?
     var description: String?
     var alerts: [Alert]?
     var stations: StationMap?
     var currentConditions: CurrentConditions?
}

struct Alert: Codable {
    var event: String
    var headline: String
    var ends: String
    var endsEpoch: Int
    var onset: String
    var onsetEpoch: Int
    var id: String
    var language: String
    var link: String
    var description: String
}

struct DayWeather : Codable {
     var datetime: Date
     var datetimeEpoch: Int
     var tempmax: Double
     var tempmin: Double
     var temp: Double
     var feelslikemax: Double
     var feelslikemin: Double
     var feelslike: Double
     var dew: Double
     var humidity: Double
     var precip: Double
     var precipprob: Double
     var precipcover: Double
     var preciptype: String?
     var snow: Double
     var snowdepth: Double
     var windgust: Double
     var windspeed: Double
     var winddir: Double
     var pressure: Double
     var cloudcover: Double
     var visibility: Double
     var solarradiation: Double
     var solarenergy: Double
     var uvindex: Double
     var severerisk: Double
     var sunrise: Date
     var sunriseEpoch: Int
     var sunset: Date
     var sunsetEpoch: Int
     var moonphase: Double
     var conditions: String
     var description: String
     var icon: String
     var stations: [String]
     var source:  String
     var hours: [HourWeather]
}

struct HourWeather : Codable {
    var datetime: Date
    var datetimeEpoch: Int
    var temp: Double
    var feelslike: Double
    var humidity: Double
    var dew: Double
    var precip: Double
    var precipprob: Double
    var snow: Double
    var snowdepth: Double
    var preciptype: String?
    var windgust: Double
    var windspeed: Double
    var winddir: Double
    var pressure: Double
    var visibility: Double
    var cloudcover: Double
    var solarradiation: Double
    var solarenergy: Double
    var uvindex: Double
    var severerisk: Double
    var conditions: String
    var icon: String
    var stations: [String]
    var source: String
}
struct Station : Codable {
    var distance: Double
    var latitude: Double
    var longitude: Double
    var useCount: Int
    var id: String
    var name: String
    var quality: Int
    var contribution: Double
}

struct StationMap : Codable {
    var array: [Station]
    
    // Define DynamicCodingKeys type needed for creating
    // decoding container from JSONDecoder
    private struct DynamicCodingKeys: CodingKey {

        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }
    init(from decoder: Decoder) throws {
        // Create a decoding container using DynamicCodingKeys
        // The container will contain all the JSON first level key
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempArray = [Station]()
        // Loop through each key (Station id) in container
        for key in container.allKeys {
            // Decode Station using key & keep decoded Station object in tempArray
            let decodedObject = try container.decode(Station.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray.append(decodedObject)
        }
        // Finish decoding all Station objects. Thus assign tempArray to array.
        array = tempArray
    }
}

struct CurrentConditions : Codable {
    var datetime: String
    var datetimeEpoch: Int
    var temp: Double
    var feelslike: Double
    var humidity: Double
    var dew: Double
    var precip: Double
    var precipprob: Double
    var snow: Double
    var snowdepth: Double
    var preciptype: String?
    var windgust: Double
    var windspeed: Double
    var winddir: Double
    var pressure: Double
    var visibility: Double
    var cloudcover: Double
    var solarradiation: Double
    var solarenergy: Double
    var uvindex: Double
    var conditions: String
    var icon: String
    var stations: [String]
    var source: String
    var sunrise: String
    var sunriseEpoch: Int
    var sunset: String
    var sunsetEpoch: Int
    var moonphase: Double
}
