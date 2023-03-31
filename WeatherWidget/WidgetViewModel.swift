//
//  WidgetViewModel.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/20.
//

import Foundation
import Alamofire
import CoreLocation

final class WidgetViewModel {
    var currentTemp: String = ""
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd HHmm"
        f.locale = Locale(identifier: Locale.current.identifier)
        f.timeZone = TimeZone(abbreviation: TimeZone.current.identifier)
        return f
    }()
    
    func getLocation(completionHandler: @escaping (String) -> Void) {
        do {
            let locationManager = WidgetLocationManager()
            let coordinate = try locationManager.updateLocation()
            requestUltraSrtNcst(coordinate: coordinate) { first in
                self.requestUltraSrtFcst(coordinate: coordinate) { second in
                    completionHandler(first + "\n" + second)
                }
            }
            
        } catch LocationError.optionalBindError {
            completionHandler("데이터를 가져오는 중입니다.")
        } catch LocationError.AuthError {
            completionHandler("위젯 사용을 위해 위치 권한을 허용해주세요")
        } catch {
            completionHandler("에러가 발생하였습니다. 잠시 기다려주세요")
        }
    }
    
    private func requestUltraSrtNcst(date: Date = Date(),
                                     coordinate: CLLocationCoordinate2D,
                                     completionHandler: @escaping (String) -> Void) {
        let date = convertUltraSrtNcst(Date())
        let dateArray = dateFormatter.string(from: date).split(separator: " ")
        let grid = convertGrid(coordinate)
        let url: String = "\(EndPoint.ultraSrtNcstURL)" + "getUltraSrtNcst?" + "base_date=\(dateArray[0])&" + "base_time=\(dateArray[1])&" + "dataType=JSON&" + "numOfRows=100&" + "pageNo=1&" + "nx=\(Int(grid.nx))&" + "ny=\(Int(grid.ny))&" + "serviceKey=\(APIKey.encodingKey)"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "accept": "application/json"]
        
        AF.request(url, headers: header).responseDecodable(of: UltraSrtNcst.self) { response in
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
                completionHandler("에러가 발생하였습니다. 잠시 기다려주세요")
            }
        }
    }
    
    private func requestUltraSrtFcst(date: Date = Date(),
                                     coordinate: CLLocationCoordinate2D,
                                     completionHandler: @escaping (String) -> Void) {
        let date = convertUltraSrtFcst(date)
        let dateArray = dateFormatter.string(from: date).split(separator: " ")
        let grid = convertGrid(coordinate)
        
        let url: String = "\(EndPoint.ultraSrtNcstURL)" + "getUltraSrtFcst?" + "base_date=\(dateArray[0])&" + "base_time=\(dateArray[1])&" + "dataType=JSON&" + "numOfRows=100&" + "pageNo=1&" + "nx=\(Int(grid.nx))&" + "ny=\(Int(grid.ny))&" + "serviceKey=\(APIKey.encodingKey)"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "accept": "application/json"]
        
        AF.request(url, headers: header).responseDecodable(of: UltraSrtFcst.self) { response in
            switch response.result {
            case .success(let data):
                let items = data.response.body.items.item
                
                for item in items where item.category == "RN1" && item.fcstValue != "강수없음" {
                    completionHandler("비올 수 있으니깐\n우산챙기세요!")
                    return
                }
                
                completionHandler("비안와요~")
            case .failure(_):
                completionHandler("에러가 발생하였습니다. 잠시 기다려주세요")
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
    
    // - Base_time: 매 시간 정각
    // - API 제공 시간(~이후): 매 시간 45분 이후
    private func convertUltraSrtFcst(_ date: Date) -> Date {
        var array = dateFormatter.string(from: date).split(separator: " ")
        guard var hour = Int(array[1]) else { return Date() }

        switch hour {
        case 0...40:
            guard let date = Int(array[0]) else { return Date() }
            array[0] = "\(date - 1)"
            hour = 46
        default:
            let hourString = "\(hour)"
            let hourArray = Array(hourString).map { String($0) }
            let changedHour = Int(hourArray[0] + hourArray[1])!
            hour = (changedHour - 2) * 100 + 46
        }

        let targetDate = dateFormatter.date(from: array[0] + " \(hour)") ?? Date()
        return targetDate
    }
}

class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        DispatchQueue.main.async {
            self.locationManager.delegate = self
            if self.locationManager.authorizationStatus == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    func updateLocation() throws -> CLLocationCoordinate2D {
        if locationManager.isAuthorizedForWidgetUpdates {
            guard let coordinate = locationManager.location?.coordinate else { throw LocationError.optionalBindError }
            return coordinate
        } else {
            throw LocationError.AuthError
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

enum LocationError: Error {
    case optionalBindError
    case AuthError
}
