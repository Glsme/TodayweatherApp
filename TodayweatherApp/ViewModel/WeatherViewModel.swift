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
    
    private var updateTimer: Timer?
    
    private let network = WeatherAPIManager.shared
    private var limmitedUpdateTime: Int = 30
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
    @Published var currentWeatherImage: WeatherImage = .no
    @Published var isUpdateded: Bool = true
    @Published var isUpdatededError: Bool = false
    
    func checkDataisUpdateded() {
        initData()
        
        if let coordinate = locationManager.locationManager.location?.coordinate {
            NotificationCenter.default.post(name: .coordinate, object: coordinate)
        } else {
            isUpdateded = false
        }
    }
    
    func initData() {
        hourWeather.removeAll()
        administrativeArea = ""
        subLocality = ""
        currentTemp = ""
        currentWeatherImage = .no
        isUpdatededError = false
    }
    
    func checkUpdatededData() {
        updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(isUpdatededData), userInfo: nil, repeats: true)
    }
    
    @objc private func isUpdatededData() {
        limmitedUpdateTime -= 1
        
        guard limmitedUpdateTime > 0 else {
            updateTimer?.invalidate()
            updateTimer = nil
            limmitedUpdateTime = 30
            isUpdateded = false
            isUpdatededError = true
            return
        }
        guard !hourWeather.isEmpty else { return }
        guard administrativeArea != "" else { return }
        guard subLocality != "" else { return }
        guard currentTemp != "" else { return }
        guard currentWeatherImage != .no else { return }

        updateTimer?.invalidate()
        updateTimer = nil
        limmitedUpdateTime = 30
        isUpdateded = false
    }
    
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
            //            dump(result)
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
        var image: WeatherImage = .no
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
    
    private func changeWeatherNoRainSnow(_ value: String, isNight: Bool) -> WeatherImage {
        switch value {
        case "1":
            return isNight ? .moon : .sun
        case "3":
            return isNight ? .cloudMoon : .cloudSun
        case "4":
            return isNight ? .cloudNight : .cloudSun
        default:
            return .no
        }
    }
    
    private func changeWeatherRainSnow(_ value: String) -> WeatherImage {
        switch value {
        case "1":
            return .cloudRain
        case "2":
            return .no //추후 디자인 받으면 수정 예정
        case "3":
            return .cloudSnow
        case "4":
            return .cloudRain
        case "5":
            return .cloudRain
        case "6":
            return .cloudRain
        case "7":
            return .no //추후 디자인 받으면 수정 예정
        default:
            return .no
        }
    }
    
    // [1, 1, 2, 2, 3, 3, ...] -> [[1,1], [2,2], [3,3] ...]
    private func filterVilageFcstData(_ data: [VilageFcstItem]) -> [[VilageFcstItem]] {
        isNowData(data) // Temp, 초단기 실황에 날씨값이 없는 관계로 기획이 정해지기 전까지 임시로 호출
        let data = data.filter { ($0.category == "TMP" || $0.category == "SKY" || $0.category == "PTY") && isFutureData($0.fcstDate, $0.fcstTime) }
        var filterData: [[VilageFcstItem]] = []
        
        var count = 0
        
        while(count < data.count - 1) {
            filterData.append([data[count], data[count + 1], data[count + 2]])
            
            count += 3
        }
        
        return filterData
    }
    
    private func isNowData(_ data: [VilageFcstItem]) {
        for item in data {
            if item.category == "PTY", item.fcstValue != "0" {
                self.currentWeatherImage = self.changeWeatherRainSnow(item.fcstValue)
                print("\(self.currentWeatherImage)")
                break
            } else if item.category == "SKY" {
                let isNight = Int(item.fcstTime)! > 1800 || Int(item.fcstTime)! < 600
                self.currentWeatherImage = self.changeWeatherNoRainSnow(item.fcstValue, isNight: isNight)
                print("\(self.currentWeatherImage)")
                break
            }
        }
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
        
        checkUpdatededData()
        requestVilageFcst(coordinate: coordinate)
        requestUltraSrtNcst(coordinate: coordinate)
        
        self.locationManager.checkUserCurrentLocation(coordinate) { [weak self] administrativeArea, subLocality in
            guard let self = self else { return }
            self.administrativeArea = administrativeArea
            self.subLocality = subLocality
        }
    }
}
