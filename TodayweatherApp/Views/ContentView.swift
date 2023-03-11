//
//  ContentView.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(r: 0, g: 0, b: 75)
                .ignoresSafeArea()
            WeatherHome()
        }
        .foregroundColor(.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
