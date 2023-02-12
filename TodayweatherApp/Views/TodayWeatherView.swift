//
//  TodayWeatherView.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/11.
//

import SwiftUI

struct TodayWeatherView: View {
    @Binding var administrativeArea: String
    @Binding var subLocality: String
    @Binding var currentTemp: String
    
    var body: some View {
        VStack {
            Text("\(administrativeArea) \(subLocality)")
                .modifier(TimeTextModifier())
            Text(currentTemp)
                .modifier(TimeTextModifier())
        }
        .padding()
    }
}

//struct TodayWeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodayWeatherView()
//    }
//}
