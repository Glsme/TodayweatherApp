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
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        VStack(spacing: .zero) {
            CurrentWeatherView(administrativeArea: $viewModel.administrativeArea,
                               subLocality: $viewModel.subLocality,
                               currentTemp: $viewModel.currentTemp)
            .frame(width: UIScreen.main.bounds.width)
//            .background(Color.gray)
            Spacer()
            HourWeatherView(hourWeather: $viewModel.hourWeather)
        }
        .onAppear {
            viewModel.locationManager.checkUserDeviceLocationAuth()
        }
    }
}

struct WeatherHome_Previews: PreviewProvider {
    static var previews: some View {
        WeatherHome()
            .environmentObject(WeatherViewModel())
    }
}
