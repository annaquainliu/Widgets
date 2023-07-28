//
//  ImageOrGifView.swift
//  Widgets
//
//  Created by Anna Liu on 7/27/23.
//

import Foundation
import SwiftUI

struct weatherOptionInfo : Hashable {
    var title : String;
    var systemImage : String;
}


struct ImageOrGifView : View {
    @State private var weatherSelection =  weatherOptionInfo(title: "sunny", systemImage: "sun.min.fill")
    @State private var timeSelection = "seconds"
    @State private var frequency = 0
    @State private var frequencyStartDate = Date()
    @State private var triggerSelection =
    ["Always" : false,
     "Weather" : false,
     "Frequency" : false,
     "Location" : false]
    
    var weatherOptions = [
        weatherOptionInfo(title: "sunny", systemImage: "sun.min.fill"),
        weatherOptionInfo(title: "cloudy", systemImage: "cloud.fill"),
        weatherOptionInfo(title: "raining", systemImage:  "cloud.heavyrain.fill"),
        weatherOptionInfo(title: "windy", systemImage: "wind.circle"),
        weatherOptionInfo(title: "snowing", systemImage: "cloud.snow.fill"),
        weatherOptionInfo(title: "thundering", systemImage: "cloud.bolt.rain")]
    
    var timeOptions = ["milliseconds", "seconds", "minutes", "hours", "days", "weeks", "months", "years"]
    
    var body : some View {
        VStack(alignment: .leading) {
            TitleText(text : "Image/Gif")
            Spacer().frame(height: 30)
            HStack {
                ImportPhoto()
                Spacer(minLength: 40)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Duration").font(.title).padding()
                        Text("*Everytime the widget is triggered, how long should it appear for?*").font(.title3)
                    }
                    HStack {
                        Text("Triggers").font(.title).padding()
                        Text("*When should the widget be triggered?*").font(.title3)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            TriggerCategoryText(text: "Always")
                        }
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
                        HStack {
                            TriggerCategoryText(text: "Frequency")
                            Text("Every").font(.title2)
                            TextField("Enter the time value", value: $frequency, format: .number)
                                           .textFieldStyle(.roundedBorder)
                            Picker("", selection: $timeSelection) {
                                ForEach(timeOptions, id: \.self) { item in
                                    Text(item)
                                }
                            }
                            Text("starting from").font(.title2)
                            DatePicker(
                                    "",
                                    selection: $frequencyStartDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                        }
                        HStack {
                            TriggerCategoryText(text: "Location")
                        }
                    }.padding([.leading, .trailing])
                    HStack {
                        Text("Time Frame").font(.title).padding()
                        Text("*When should the widget be triggerable?*").font(.title3)
                    }
                }
            }.padding()
        }.padding()
         .frame(width: 1000)
    }
}

struct ImageOrGifView_Providers: PreviewProvider {
    static var previews: some View {
        ImageOrGifView()
    }
}
