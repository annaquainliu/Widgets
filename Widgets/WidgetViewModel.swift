//
//  WidgetViewModel.swift
//  Widgets
//
//  Created by Anna Liu on 7/30/23.
//

import Foundation

class WidgetViewModel : ObservableObject {
    @Published private var widgetType : String = ""
    @Published private var selectedWeather : String = ""
    
    init(widgetType : String, duration : Duration, timeFrame : TimeFrame) {
        
    }
    
}
