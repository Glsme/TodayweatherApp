//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by Seokjune Hong on 2023/02/14.
//

import WidgetKit
import SwiftUI
import Intents
import Combine

struct Provider: IntentTimelineProvider {
    // 특정 내용이 없는 시각적 표현
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    // WidgetKit이 위젯이 일시적인 상황에 나타나면 호출하는 함수
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    // 현재 시간과 위젯을 업데이트할 향후 시간에 대한 타임라인 항목을 제공
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

//struct testEntry:

struct WeatherWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Image(systemName: "person")
            Text("\(entry.date)")
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "오늘날씨야"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: ConfigurationIntent.self,
                            provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘 날씨야~")
        .description("위젯 크기를 설정해주세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
    
}

struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
