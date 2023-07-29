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

protocol TriggerOption {
    var body: any View { get }
}

struct ImageOrGifView : View {
    @State private var weatherSelection =  weatherOptionInfo(title: "sunny", systemImage: "sun.min.fill")
    
    @State private var freqMeasurement = "seconds"
    @State private var frequency = 0
    @State private var frequencyStartDate = Date()
    
    @State private var triggerSelection = "Always"
    
    @State private var duration = 0
    @State private var durationMeasurement = "seconds"
    
    @State private var timeFrameSelection = "Always"
    @State private var timeFrameStart = Date()
    @State private var timeFrameEnd = Date()
    
    var weatherOptions = [
        weatherOptionInfo(title: "sunny", systemImage: "sun.min.fill"),
        weatherOptionInfo(title: "cloudy", systemImage: "cloud.fill"),
        weatherOptionInfo(title: "raining", systemImage:  "cloud.heavyrain.fill"),
        weatherOptionInfo(title: "windy", systemImage: "wind.circle"),
        weatherOptionInfo(title: "snowing", systemImage: "cloud.snow.fill"),
        weatherOptionInfo(title: "thundering", systemImage: "cloud.bolt.rain")]
    
    var timeOptions = ["milliseconds", "seconds", "minutes", "hours", "days", "weeks", "months", "years"]
    
    func makeRadioOption(title : String, view : some View, selection : String) -> some View {
        return view.tag(title).disabled(selection != title)
    }
    
    func makeTimeMeasurementMenu(selection : Binding<String>) -> some View {
        return Picker("", selection: selection) {
            ForEach(timeOptions, id: \.self) { item in
                Text(item)
            }
        }.pickerStyle(MenuPickerStyle())
    }
   
    var body : some View {
        VStack(alignment: .leading) {
            TitleText(text : "Image/Gif")
            Spacer().frame(height: 30)
            HStack {
                ImportPhoto()
                Spacer(minLength: 40)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Triggers").font(.title).padding()
                        Text("*When should the widget be visible?*").font(.title3)
                    }
                    VStack(alignment: .leading) {
                        Picker(selection: $triggerSelection, label: Text("")) {
                            makeRadioOption(
                                title: "Always",
                                view: HStack {
                                    TriggerCategoryText(text: "Always")},
                                selection: triggerSelection)
                            makeRadioOption(
                                title: "Weather",
                                view: HStack {
                                    TriggerCategoryText(text: "Weather")
                                    Picker("", selection: $weatherSelection) {
                                        ForEach(weatherOptions, id: \.self) { item in
                                            HStack {
                                                Text("Whenever it is " + item.title)
                                                Image(systemName: item.systemImage)
                                            }
                                        }
                                    }.pickerStyle(.menu)},
                                selection: triggerSelection)
                            makeRadioOption(
                                title: "Frequency",
                                view: HStack {
                                    TriggerCategoryText(text: "Frequency")
                                    Text("Every").font(.title2)
                                    TextField("Enter the time value", value: $frequency, format: .number)
                                                   .textFieldStyle(.roundedBorder)
                                    makeTimeMeasurementMenu(selection: $freqMeasurement)
                                    Text("starting from").font(.title2)
                                    DatePicker(
                                            "",
                                            selection: $frequencyStartDate,
                                            displayedComponents: [.date, .hourAndMinute]
                                    )},
                                selection: triggerSelection)
                            makeRadioOption(
                                title: "Location",
                                view: HStack {
                                    TriggerCategoryText(text: "Location")
                            }, selection: triggerSelection)
                        }.pickerStyle(RadioGroupPickerStyle())
                    }.padding([.leading, .trailing])
                    HStack {
                        Text("Duration").font(.title).padding()
                        Text("*Everytime the widget is triggered, how long should it appear for?*").font(.title3)
                    }
                    VStack {
                        HStack {
                            TextField("Enter the time value", value: $duration, format: .number)
                                .textFieldStyle(.roundedBorder)
                            makeTimeMeasurementMenu(selection: $durationMeasurement)
                        }.frame(width: 400)
                    }.padding([.leading, .trailing])
                     .disabled(triggerSelection == "Always")
                    HStack {
                        Text("Time Frame").font(.title).padding()
                        Text("*When should the widget be triggerable?*").font(.title3)
                    }
                    VStack {
                        Picker(selection: $timeFrameSelection, label: Text("")) {
                            makeRadioOption(
                                title: "Always",
                                view: Text("Always").font(.title2),
                                selection: timeFrameSelection)
                            makeRadioOption(
                                title: "timeFrame",
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
