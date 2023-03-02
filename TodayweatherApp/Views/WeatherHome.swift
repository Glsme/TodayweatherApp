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
            ZStack {
                Color.blue
                    .edgesIgnoringSafeArea(.top)
                Color(red: 167/255, green: 219/255, blue: 255/255)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.65)
                
                CurrentWeatherView(administrativeArea: $viewModel.administrativeArea,
                                   subLocality: $viewModel.subLocality,
                                   currentTemp: $viewModel.currentTemp)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.65)
                .background(Color.blue)
                .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
            }
            
            ZStack {
                Spacer()
            }
//            .background(Color.red)
            
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
