//
//  HourWeatherView.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import SwiftUI
import MapKit
import CoreLocation

struct HourWeatherView: View {
    @StateObject private var network = WeatherAPIManager.shared
    private let geoConverter = GeoConverter()
    @StateObject private var viewModel = HourWeatherViewModel()
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.hourWeather, id: \.self) { datas in
                        DayWeatherItem(datas: datas)
                    }
                }
                .padding()
            }
            .onAppear {
                viewModel.requestVilageFcst(coordinate: CLLocationCoordinate2D(latitude: 37.621068, longitude: 127.041060))
            }
        }
        .background(Color.blue)
        .cornerRadius(15)
        .padding()
    }
}

struct HourWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        HourWeatherView()
        //            .environmentObject(HourWeatherViewModel())
    }
}
