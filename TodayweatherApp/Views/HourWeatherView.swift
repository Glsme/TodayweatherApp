//
//  HourWeatherView.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import SwiftUI

struct HourWeatherView: View {
    @Binding var hourWeather: [[HourWeather]]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color.white.opacity(0.7))
                .frame(height: UIScreen.main.bounds.height * 0.2)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(hourWeather, id: \.self) { datas in
                        DayWeatherItem(datas: datas)
                    }
                }
                .padding()
            }
        }
//        .background(Color.white.opacity(0.7))
//        .cornerRadius(15)
        .padding()
    }
}

//struct HourWeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        HourWeatherView(hourWeather: )
//    }
//}
