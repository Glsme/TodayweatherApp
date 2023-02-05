//
//  ContentView.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/02.
//

import SwiftUI

struct ContentView: View {
    @State var text: String = "hi 😎"
    @StateObject private var network = WeatherAPIManager.shared
    
    var body: some View {
        List {
            ForEach(network.weathers, id: \.self) { result in
                Text("\(result.category): \(result.obsrValue)")
            }
        }.onAppear {
            network.requestSomething(date: Date())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
