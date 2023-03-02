//
//  TodayWeatherView.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/11.
//

import SwiftUI

struct CurrentWeatherView: View {
    @Binding var administrativeArea: String
    @Binding var subLocality: String
    @Binding var currentTemp: String
    
    var body: some View {
        VStack {
//            Spacer()
            Text("\(administrativeArea) \(subLocality)")
                .modifier(LocationTextModifier())
//            Text("\(Date())")
//                .modifier(LocationTextModifier())
//            Spacer()
            Image("sun.max.fill")
                .resizable()
                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.8, alignment: .center)
            Text(currentTemp)
                .modifier(CurrentTempTextModifer())
//            Spacer(minLength: UIScreen.main.bounds.height * 0.1)
        }
    }
}

//struct CurrentWeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrentWeatherView(administrativeArea: <#T##Binding<String>#>, subLocality: <#T##Binding<String>#>, currentTemp: <#T##Binding<String>#>)
//    }
//}
