//
//  DaysWeatherItem.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import SwiftUI

struct DayWeatherItem: View {
    var datas: [HourWeather]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(datas.isEmpty ? "" : datas[0].date)
                .modifier(TempTextModifier())
            Divider()
                .background(Color.white)
            HStack {
                ForEach(datas, id: \.self) { data in
                    HourWeatherItem(weatherData: data)
                }
            }
        }
    }
}

struct DaysWeatherItem_Previews: PreviewProvider {
    static var previews: some View {
        DayWeatherItem(datas: [])
    }
}
