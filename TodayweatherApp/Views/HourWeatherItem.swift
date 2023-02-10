//
//  HourWeatherItem.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import SwiftUI

struct HourWeatherItem: View {
    var weatherData: HourWeather
    
    var body: some View {
        VStack {
            Text(weatherData.time)
                .modifier(BodyTextModifier())
            Spacer()
            Image(systemName: weatherData.img)
            Spacer()
            Text(weatherData.temp)
                .modifier(BodyTextModifier())
        }
        .padding()
    }
}

struct HourWeatherItem_Previews: PreviewProvider {
    static var previews: some View {
        HourWeatherItem(weatherData: HourWeather())
    }
}
