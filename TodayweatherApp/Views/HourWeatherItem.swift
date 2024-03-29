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
                .modifier(TimeTextModifier())
            Image(weatherData.img.rawValue)
                .resizable()
                .frame(width: 50, height: 50)
                .animation(.easeInOut(duration: 2), value: true)
            Text(weatherData.temp)
                .modifier(TempTextModifier())
        }
        .padding([.leading, .trailing], 4)
    }
}

struct HourWeatherItem_Previews: PreviewProvider {
    static var previews: some View {
        HourWeatherItem(weatherData: HourWeather())
    }
}
