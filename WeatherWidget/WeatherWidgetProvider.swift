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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image: "moon", dumy: "")
    }
    
    // WidgetKit이 위젯이 일시적인 상황에 나타나면 호출하는 함수
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), image: "moon", dumy: "")
        completion(entry)
    }
    
    // 현재 시간과 위젯을 업데이트할 향후 시간에 대한 타임라인 항목을 제공
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        viewModel.testLocation { temp in
            var entries: [SimpleEntry] = []
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
                
                let entry = SimpleEntry(date: entryDate, image: "moon", dumy: "\(temp)")
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: String
    let dumy: String
}
