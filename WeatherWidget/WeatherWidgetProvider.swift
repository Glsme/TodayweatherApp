//
//  WeatherWidgetProvider.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/19.
//

import WidgetKit
import SwiftUI
import Intents
import Combine
import CoreLocation

struct Provider: IntentTimelineProvider {
    let viewModel = WidgetViewModel()
    // 특정 내용이 없는 시각적 표현
    func placeholder(in context: Context) -> WeatherData {
        WeatherData(date: Date(), text: "")
    }
    
    // WidgetKit이 위젯이 일시적인 상황에 나타나면 호출하는 함수
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WeatherData) -> ()) {
        let entry = WeatherData(date: Date(), text: "")
        completion(entry)
    }
    
    // 현재 시간과 위젯을 업데이트할 향후 시간에 대한 타임라인 항목을 제공
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<WeatherData>) -> ()) {
        viewModel.getLocation { result in
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let refreshTime = result.bool ? 20 : 3
            let currentDate = Date()
            let entryDate = Calendar.current.date(byAdding: .minute, value: refreshTime, to: currentDate)!
            let entry = WeatherData(date: entryDate, text: "\(result.value)")
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}
