//
//  HourWeatherViewModel.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import Foundation
import CoreLocation

final class HourWeatherViewModel: NSObject, ObservableObject {
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    private let network = WeatherAPIManager.shared
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: Locale.current.identifier)
        f.timeZone = TimeZone(abbreviation: TimeZone.current.identifier)
        f.dateFormat = "a h시"
        return f
    }()
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: Locale.current.identifier)
        f.timeZone = TimeZone(abbreviation: TimeZone.current.identifier)
        f.dateFormat = "M월 dd일"
        return f
    }()
    
    @Published var hourWeather: [[HourWeather]] = [[]]
    @Published var administrativeArea: String = ""
    @Published var subLocality: String = ""
    
    private func requestVilageFcst(date: Date = Date(), coordinate: CLLocationCoordinate2D) {
        network.requestVilageFcst(date: date, coordinate: coordinate) { [weak self] result in
            guard let self = self else { return }
            let data = self.convertVilageFcstData(result)
            self.hourWeather = self.groupHourWeatherByDate(data)
        }
    }
    
    private func requestUltraSrtNcst(date: Date = Date(), coordinate: CLLocationCoordinate2D) {
        network.requestUltraSrtNcst(date: date, coordinate: coordinate) { [weak self] result in
            guard let self = self else { return }
            print("!!!", result)
        }
    }
    
    private func convertDateKo(_ dateString: String) -> String {
        let dateArray = Array(dateString).map { String($0) }
        let month = Int(dateArray[4] + dateArray[5])!
        let day = Int(dateArray[6] + dateArray[7])!
        let dateComponents = DateComponents(month: month, day: day)
        let calendar = Calendar.current.date(from: dateComponents) ?? Date()
        
        return dateFormatter.string(from: calendar)
    }
    
    private func convertHourKo(_ hourString: String) -> String {
        let hourArray = Array(hourString).map { String($0) }
        let hour = Int(hourArray[0] + hourArray[1])!
        let hourComponents = DateComponents(hour: hour)
        let calendar = Calendar.current.date(from: hourComponents) ?? Date()
        let time = timeFormatter.string(from: calendar)
        
        return time == "AM 12시" ? "AM 0시" : time
    }
    
    private func groupHourWeatherByDate(_ data: [HourWeather]) -> [[HourWeather]] {
        var tempArray: [HourWeather] = []
        var resultAraray: [[HourWeather]] = []
        var targetDate: String = data[0].date
        
        for count in 0..<data.count {
            if targetDate == data[count].date {
                tempArray.append(data[count])
            } else {
                resultAraray.append(tempArray)
                targetDate = data[count].date
                tempArray.removeAll()
                tempArray.append(data[count])
            }
        }
        
        resultAraray.append(tempArray)
        
        return resultAraray
    }
    
    private func convertVilageFcstData(_ datas: [VilageFcstItem]) -> [HourWeather] {
        var hourWeather: [HourWeather] = []
        var image: String = ""
        let vilageFcstData: [[VilageFcstItem]] = filterVilageFcstData(datas)
        var isNight: Bool = false
        
        vilageFcstData.forEach {
            isNight = Int($0[0].fcstTime)! > 1800 || Int($0[0].fcstTime)! < 600
            
            if $0[2].category == "PTY", $0[2].fcstValue == "0" {
                image = changeWeatherNoRainSnow($0[1].fcstValue, isNight: isNight)
            } else {
                image = changeWeatherRainSnow($0[2].fcstValue)
            }
            
            let data = HourWeather(date: convertDateKo($0[0].fcstDate),
                                   time: hourWeather.isEmpty ? "현재" : convertHourKo($0[0].fcstTime),
                                   img: image,
                                   temp: "\($0[0].fcstValue)℃",
                                   UUID: UUID().uuidString)
            hourWeather.append(data)
        }
        
        return hourWeather
    }
    
    private func changeWeatherNoRainSnow(_ value: String, isNight: Bool) -> String {
        switch value {
        case "1":
            return isNight ? "moon.stars.fill" : "sun.max.fill"
        case "3":
            return isNight ? "cloud.moon.fill": "cloud.sun.fill"
        case "4":
            return "cloud.fill"
        default:
            return ""
        }
    }
    
    private func changeWeatherRainSnow(_ value: String) -> String {
        switch value {
        case "1":
            return "cloud.rain.fill"
        case "2":
            return "cloud.sleet.fill"
        case "3":
            return "cloud.snow.fill"
        case "4":
            return "cloud.rain.fill"
        case "5":
            return "cloud.rain.fill"
        case "6":
            return "cloud.rain.fill"
        case "7":
            return "wind.snow"
        default:
            return ""
        }
    }
    
    // [1, 1, 2, 2, 3, 3, ...] -> [[1,1], [2,2], [3,3] ...]
    private func filterVilageFcstData(_ data: [VilageFcstItem]) -> [[VilageFcstItem]] {
        let data = data.filter { $0.category == "TMP" || $0.category == "SKY" || $0.category == "PTY" }
        var filterData: [[VilageFcstItem]] = []
        
        var count = 0
        
        while(count < data.count - 1) {
            filterData.append([data[count], data[count + 1], data[count + 2]])
            
            count += 3
        }
        
        return filterData
    }
}

//위치 권한 관련
extension HourWeatherViewModel: CLLocationManagerDelegate {
    func checkUserDeviceLocationAuth() {
        checkUserCurrentLocationAuth(locationManager.authorizationStatus)
    }
    
    private func checkUserCurrentLocationAuth(_ authStatus: CLAuthorizationStatus) {
        switch authStatus {
        case .notDetermined:
            print("not Determined")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("restricted or denied, 아이폰 설정 유도")
        case .authorizedWhenInUse:
            print("when in use")
            locationManager.startUpdatingLocation()
        default:
            print("Default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            requestVilageFcst(coordinate: coordinate)
            requestUltraSrtNcst(coordinate: coordinate)
            checkUserCurrentLocation(coordinate)
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkUserDeviceLocationAuth()
    }
    
    // 사용자 위치 변환 및 저장
    func checkUserCurrentLocation(_ coordinate: CLLocationCoordinate2D) {
        let findLocation: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geoCoder: CLGeocoder = CLGeocoder()
        let local: Locale = Locale(identifier: "Ko-kr") // Korea
        geoCoder.reverseGeocodeLocation(findLocation, preferredLocale: local) { [weak self] place, _ in
            guard let self = self else { return }
            if let address: [CLPlacemark] = place {
                self.administrativeArea = address.last?.administrativeArea ?? "지역 오류"
                self.subLocality = address.last?.subLocality ?? "지역 오류"
            }
        }
    }
}
