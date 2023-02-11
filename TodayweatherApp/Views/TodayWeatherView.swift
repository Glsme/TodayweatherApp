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
    
    var body: some View {
        VStack {
            Text("\(administrativeArea) \(subLocality)")
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
