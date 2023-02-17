//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by Seokjune Hong on 2023/02/14.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        
        if #available(iOS 16.1, *) {
//            WeatherWidgetLiveActivity()
        }
    }
}
