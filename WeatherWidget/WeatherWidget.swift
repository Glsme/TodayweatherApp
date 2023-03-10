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

struct WeatherWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Image("sun")
//                .frame(width: 100, height: 100)
//            Text("\(entry.date)")
            Text("\(entry.dumy)")
                .font(.custom(Fonts.semiBold.rawValue, size: 14))
                .foregroundColor(.white)
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "오늘날씨야"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: ConfigurationIntent.self,
                            provider: Provider()) { entry in
            ZStack {
                Color.blue
                WeatherWidgetEntryView(entry: entry)
            }
        }
                            .configurationDisplayName("오늘 날씨야~")
                            .description("위젯 크기를 설정해주세요.")
                            .supportedFamilies([.systemSmall, .systemMedium])
    }
    
}

//struct WeatherWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherWidgetEntryView(entry: SimpleEntry(date: Date(),
//                                                  configuration: ConfigurationIntent(),
//                                                  image: "",
//                                                  dumy: ""))
//        .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
