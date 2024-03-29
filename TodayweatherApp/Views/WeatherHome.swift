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
                            .disabled(viewModel.isUpdateded)
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
        .alert(isPresented: $viewModel.isUpdatededError, content: {
            Alert(title: Text(""),
                  message: Text("데이터를 불러오는데 실패하였습니다.\n우측 위 버튼을 눌러 다시 시도해주세요."),
                  dismissButton: .default(Text("확인")))
        })
        .alert(isPresented: $viewModel.isAuthorizedLocation, content: {
            Alert(title: Text("위치 권한 설정"),
                  message: Text("앱 사용을 위해 위치 권한 설정 후 이용해주세요"),
                  primaryButton: .default(Text("설정으로 이동"), action: {
                if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSetting)
                }
            }),
                  secondaryButton: .cancel(Text("취소")))
        })
        .onAppear {
            viewModel.checkLocation()
        }
    }
}

struct WeatherHome_Previews: PreviewProvider {
    static var previews: some View {
        WeatherHome()
            .environmentObject(WeatherViewModel())
    }
}
