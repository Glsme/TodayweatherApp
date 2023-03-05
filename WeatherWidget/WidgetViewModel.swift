//
//  WidgetViewModel.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/20.
//

import Foundation
import Alamofire
import CoreLocation

class WidgetViewModel {
    var currentTemp: String = ""
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd HHmm"
        f.locale = Locale(identifier: Locale.current.identifier)
        f.timeZone = TimeZone(abbreviation: TimeZone.current.identifier)
        return f
    }()
    
    func testLocation(completionHandler: @escaping (String) -> Void) {
        let locationManager = LocationManager()
        locationManager.checkUserDeviceLocationAuth()
        requestUltraSrtNcst(coordinate: CLLocationCoordinate2D(latitude: 37, longitude: 128)) { string in
            completionHandler(string)
        }
//        locationManager.requestLocation { [weak self] coordinate in
//            guard let self = self else { return }
//            self.requestUltraSrtNcst(coordinate: coordinate) { result in
//                completionHandler(result)
//            }
//        }
    }
    
    private func requestUltraSrtNcst(date: Date = Date(),
                                     coordinate: CLLocationCoordinate2D,
                                     completionHandler: @escaping (String) -> Void) {
        let date = convertUltraSrtNcst(Date())
        let dateArray = dateFormatter.string(from: date).split(separator: " ")
        let grid = convertGrid(coordinate)
        
        let url: String = "\(EndPoint.ultraSrtNcstURL)" + "getUltraSrtNcst?" + "base_date=\(dateArray[0])&" + "base_time=\(dateArray[1])&" + "dataType=JSON&" + "numOfRows=100&" + "pageNo=1&" + "nx=\(Int(grid.nx))&" + "ny=\(Int(grid.ny))&" + "serviceKey=\(APIKey.encodingKey)"
        
        AF.request(url).responseDecodable(of: UltraSrtNcst.self) { response in
            switch response.result {
            case .success(let data):
                let items = data.response.body.items.item
                items.forEach {
                    if $0.category == "T1H" {
                        completionHandler($0.obsrValue + " º")
                        return
                    }
                }
            case .failure(_):
                break
//                completionHandler("\(response.error?.localizedDescription)!")
            }
        }

    }
    
    private func convertGrid(_ coordinate: CLLocationCoordinate2D) -> Grid {
        let point = GeographicPoint(x: coordinate.longitude, y: coordinate.latitude)
        guard let convertedPoint = GeoConverter().wgs84ToGrid(point) else { return Grid(nx: 0, ny: 0) }
        return Grid(nx: convertedPoint.x, ny: convertedPoint.y)
    }
    
    // - Base_time: 매 시간 정각
    // - API 제공 시간(~이후): 매 시간 40분 이후
    private func convertUltraSrtNcst(_ date: Date) -> Date {
        var array = dateFormatter.string(from: date).split(separator: " ")
        guard var hour = Int(array[1]) else { return Date() }
        
        switch hour {
        case 0...40:
            guard let date = Int(array[0]) else { return Date() }
            array[0] = "\(date - 1)"
            hour = 41
        case ...940:
            hour = hour - 100 + 1
            let targetDate = dateFormatter.date(from: array[0] + " 0\(hour)") ?? Date()
            return targetDate
        default:
            let hourString = "\(hour)"
            let hourArray = Array(hourString).map { String($0) }
            let changedHour = Int(hourArray[0] + hourArray[1])!
            hour = (changedHour - 2) * 100 + 41
        }
        
//        print("초단기 실황 시간 : \(hour)")
        let targetDate = dateFormatter.date(from: array[0] + " \(hour)") ?? Date()
        return targetDate
    }
}
