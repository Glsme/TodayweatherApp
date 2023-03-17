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
        switch family {
        case .accessoryCircular:
            VStack {
                Image("sun")
                //                .frame(width: 100, height: 100)
                //            Text("\(entry.date)")
                Text("\(entry.dumy)")
                    .font(.custom(Fonts.bold.rawValue, size: 16))
                    .foregroundColor(.white)
            }
        default:
            VStack {
                Image("sun")
                //                .frame(width: 100, height: 100)
                //            Text("\(entry.date)")
                Text("\(entry.dumy)")
                    .font(.custom(Fonts.bold.rawValue, size: 16))
                    .foregroundColor(.white)
            }
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "오늘날씨야"
    let widgets: [WidgetFamily] = {
        if #available(iOS 16.0, *) {
            return [.systemSmall ,.systemMedium, .accessoryCircular, .accessoryRectangular]
        } else {
            return [.systemSmall, .systemMedium]
        }
    }()
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
                            .supportedFamilies(widgets)
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
