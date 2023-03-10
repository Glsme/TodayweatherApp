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
        
        ZStack {
            VStack(spacing: .zero) {
                
                ZStack {
                    LinearGradient(colors: [Color(red: 167/255, green: 219/255, blue: 255/255),
                                            Color(red: 134/255, green: 179/255, blue: 211/255)],
                                   startPoint: .top,
                                   endPoint: .bottom)
                    .cornerRadius(30, corners: [.bottomRight, .bottomLeft])
                    .shadow(color: Color(red: 89/255, green: 117/255, blue: 138/255), radius: 5, x: 0 ,y: 3)
                    .ignoresSafeArea(.all, edges: .top)
                    
                    CurrentWeatherView(administrativeArea: $viewModel.administrativeArea,
                                       subLocality: $viewModel.subLocality,
                                       currentTemp: $viewModel.currentTemp,
                                       currentImage: $viewModel.currentWeatherImage)
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                viewModel.isUpdateded = true
                                viewModel.checkDataisUpdateded()
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                            }
                        }
                        .padding(.trailing)
                        Spacer()
                    }
                }
                Spacer()
                
                HourWeatherView(hourWeather: $viewModel.hourWeather)
            }
            
            if viewModel.isUpdateded {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
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
