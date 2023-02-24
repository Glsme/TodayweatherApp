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
    // 특정 내용이 없는 시각적 표현
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), image: "", dumy: "")
    }
    
    // WidgetKit이 위젯이 일시적인 상황에 나타나면 호출하는 함수
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, image: "", dumy: "")
        completion(entry)
    }
    
    // 현재 시간과 위젯을 업데이트할 향후 시간에 대한 타임라인 항목을 제공
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            
            let entry = SimpleEntry(date: entryDate, configuration: configuration, image: "moon.fill", dumy: "\(hourOffset)")
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func fetchLocation() -> String {
        let locationManager = LocationManager()
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
        locationManager.checkUserDeviceLocationAuth()
        locationManager.requestLocation { result in
            coordinate = result
        }
        
        return "\(coordinate)"
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let image: String
    let dumy: String
}
