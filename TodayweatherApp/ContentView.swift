//
//  ContentView.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/02.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var network = WeatherAPIManager.shared
    private let geoConverter = GeoConverter()
    var body: some View {
        List {
            ForEach(network.weatherData, id: \.self) { result in
                Text("\(result.category): \(result.obsrValue)")
            }
        }
        .listStyle(.grouped)
        .onAppear {
            network.requestSomething(date: Date(), coordinate: CLLocationCoordinate2D(latitude: 37.621068, longitude: 127.041060))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
