//
//  WeatherHome.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import SwiftUI
import MapKit
import CoreLocation

struct WeatherHome: View {
    @StateObject private var network = WeatherAPIManager.shared
    private let geoConverter = GeoConverter()
    
    var body: some View {
        ScrollView {
            HourWeatherView()
        }
    }
}

struct WeatherHome_Previews: PreviewProvider {
    static var previews: some View {
        WeatherHome()
//            .environmentObject(HourWeatherViewModel())
    }
}
