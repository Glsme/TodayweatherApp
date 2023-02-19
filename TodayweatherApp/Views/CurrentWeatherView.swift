//
//  TodayWeatherView.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/11.
//

import SwiftUI

struct CurrentWeatherView: View {
    @Binding var administrativeArea: String
    @Binding var subLocality: String
    @Binding var currentTemp: String
    
    var body: some View {
        VStack {
            Text("\(administrativeArea) \(subLocality)")
                .modifier(LocationTextModifier())
            Spacer()
            Image("sun.max.fill")
                .resizable()
                .aspectRatio(CGSize(width: 200, height: 200), contentMode: .fill)
            Text(currentTemp)
                .modifier(CurrentTempTextModifer())
        }
        .padding()
    }
}

//struct TodayWeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodayWeatherView()
//    }
//}
