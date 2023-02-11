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
        Text(administrativeArea)
        Text(subLocality)
    }
}

//struct TodayWeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodayWeatherView()
//    }
//}
