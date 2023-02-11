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
    @StateObject private var viewModel = HourWeatherViewModel()
    
    var body: some View {
        ScrollView {
            TodayWeatherView(administrativeArea: $viewModel.administrativeArea,
                             subLocality: $viewModel.subLocality)
            HourWeatherView(hourWeather: $viewModel.hourWeather)
        }
        .onAppear {
            viewModel.checkUserDeviceLocationAuth()
        }
    }
}

struct WeatherHome_Previews: PreviewProvider {
    static var previews: some View {
        WeatherHome()
//            .environmentObject(HourWeatherViewModel())
    }
}
