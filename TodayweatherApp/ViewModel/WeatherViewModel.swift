//
//  HourWeatherViewModel.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import Foundation
import CoreLocation

final class WeatherViewModel: NSObject, ObservableObject {
    //    let locationManager = CLLocationManager()
    let locationManager = LocationManager()
    
    override init() {
        super.init()
        print("View Model init")
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserLocation(_:)), name: .coordinate, object: nil)
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
        f.dateFormat = "M월 d일"
        return f
    }()
    
    // View 관련 프로퍼티
    @Published var hourWeather: [[HourWeather]] = [[]]
    @Published var administrativeArea: String = ""
    @Published var subLocality: String = ""
    @Published var currentTemp: String = ""
    @Published var currentWeatherImage: String = ""
    
    private func requestVilageFcst(date: Date = Date(), coordinate: CLLocationCoordinate2D) {
        network.requestVilageFcst(date: date, coordinate: coordinate) { [weak self] result in
            guard let self = self else { return }
            let data = self.convertVilageFcstData(result)
            self.hourWeather.removeAll()
            self.hourWeather = self.groupHourWeatherByDate(data)
        }
    }
    
    //    private func requestUltraSrtFcst(date: Date = Date(), coordinate: CLLocationCoordinate2D) {
    //        network.requestUltraSrtFcst(date: date, coordinate: coordinate) { result in
    //            dump(result)
    //        }
    //    }
    
    private func requestUltraSrtNcst(date: Date = Date(), coordinate: CLLocationCoordinate2D) {
        network.requestUltraSrtNcst(date: date, coordinate: coordinate) { [weak self] result in
            guard let self = self else { return }
            result.forEach {
                if $0.category == "T1H" {
                    self.currentTemp = $0.obsrValue + " º"
                }
            }
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
                                   time: convertHourKo($0[0].fcstTime), // hourWeather.isEmpty ? "현재" : convertHourKo($0[0].fcstTime),
                                   img: image,
                                   temp: "\($0[0].fcstValue) º",
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
        let data = data.filter { ($0.category == "TMP" || $0.category == "SKY" || $0.category == "PTY") && isFutureData($0.fcstDate, $0.fcstTime) }
        var filterData: [[VilageFcstItem]] = []
        
        var count = 0
        
        while(count < data.count - 1) {
            filterData.append([data[count], data[count + 1], data[count + 2]])
            
            count += 3
        }
        
        return filterData
    }
    
    private func isFutureData(_ fcstDate: String, _ fcstTime: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd HHmm"
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.timeZone = TimeZone(abbreviation: TimeZone.current.identifier)
        
        let date = dateFormatter.string(from: Date())
        let dateArray = date.split(separator: " ").map { String($0) }
        
        // 날짜가 현재 날짜보다 크면 true, 아닐 경우 다음 flow 진행
        if Int(dateArray[0])! < Int(fcstDate)! {
            return true
        }
        
        // 시간이 현재 시간보다 크면 true
        if Int(dateArray[1])! < Int(fcstTime)! {
            return true
        }
        
        return false
    }
    
    @objc func updateUserLocation(_ notification: Notification) {
        print(#function)
        guard let coordinate = notification.object as? CLLocationCoordinate2D else { return }
        
        requestVilageFcst(coordinate: coordinate)
        requestUltraSrtNcst(coordinate: coordinate)
        
        self.locationManager.checkUserCurrentLocation(coordinate) { [weak self] administrativeArea, subLocality in
            guard let self = self else { return }
            self.administrativeArea = administrativeArea
            self.subLocality = subLocality
        }
    }
}
