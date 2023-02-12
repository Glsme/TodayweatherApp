//
//  WeatherAPIManager.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/04.
//

import Foundation
import MapKit

import Alamofire

final class WeatherAPIManager: NSObject, ObservableObject {
    static let shared = WeatherAPIManager()
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd HHmm"
        f.locale = Locale(identifier: Locale.current.identifier)
        f.timeZone = TimeZone(abbreviation: TimeZone.current.identifier)
        return f
    }()
    
    private let geoConverter = GeoConverter()
    
    private override init() { }
    
    func requestUltraSrtNcst(date: Date, coordinate: CLLocationCoordinate2D, completion: @escaping ([UltraSrtNcstItem]) -> Void) {
        let convertedDate: Date = convertUltraSrtNcst(date)
        let router = WeatherAPIRouter.ultraSrtNcst(date: convertedDate, grid: convertGrid(coordinate))
        
        AF.request(router).responseDecodable(of: UltraSrtNcst.self) {response in
            switch response.result {
            case .success(let data):
                let items = data.response.body.items.item
                completion(items)
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    func requestUltraSrtFcst(date: Date, coordinate: CLLocationCoordinate2D, completion: @escaping ([UltraSrtFcstItem]) -> Void) {
        let router = WeatherAPIRouter.ultraSrtFcst(date: date, grid: convertGrid(coordinate))
        
        AF.request(router).responseDecodable(of: UltraSrtFcst.self) {response in
            switch response.result {
            case .success(let data):
                let items = data.response.body.items.item
                completion(items)
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    func requestVilageFcst(date: Date, coordinate: CLLocationCoordinate2D, completion: @escaping ([VilageFcstItem]) -> Void) {
        let convertedDate: Date = convertVilageFcstDate(date)
        let router = WeatherAPIRouter.vilageFcst(date: convertedDate, grid: convertGrid(coordinate))
        
        AF.request(router).responseDecodable(of: VilageFcst.self) {response in
            switch response.result {
            case .success(let data):
                let items = data.response.body.items.item
                completion(items)
            case .failure(let error):
                dump(error)
                print(error.localizedDescription)
            }
        }
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
        default:
            let hourString = "\(hour)"
            let hourArray = Array(hourString).map { String($0) }
            let changedHour = Int(hourArray[0] + hourArray[1])!
            hour = (changedHour - 2) * 100 + 40
        }
        
        print("초단기 실황 시간 : \(hour)")
        let targetDate = dateFormatter.date(from: array[0] + " \(hour)") ?? Date()
        return targetDate
    }
    
    // - Base_time : 0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300 (1일 8회)
    // - API 제공 시간(~이후) : 02:10, 05:10, 08:10, 11:10, 14:10, 17:10, 20:10, 23:10
    private func convertVilageFcstDate(_ date: Date) -> Date {
        var array = dateFormatter.string(from: date).split(separator: " ")
        guard var hour = Int(array[1]) else { return Date() }
        
        switch hour {
        case 0...210:
            guard let date = Int(array[0]) else { return Date() }
            array[0] = "\(date - 1)"
            hour = 2300
        case 211...510:
            hour = 210
        case 511...810:
            hour = 510
        case 811...1110:
            hour = 810
        case 1111...1410:
            hour = 1110
        case 1411...1710:
            hour = 1410
        case 1711...2010:
            hour = 1710
        case 2011...2310:
            hour = 2010
        case 2311...2399:
            hour = 2310
        default:
            break
        }
        
        print("단기 예보 시간: \(hour)")
        let targetDate = dateFormatter.date(from: array[0] + " \(hour)") ?? Date()
        return targetDate
    }
    
    private func convertGrid(_ coordinate: CLLocationCoordinate2D) -> Grid {
        let point = GeographicPoint(x: coordinate.longitude, y: coordinate.latitude)
        guard let convertedPoint = geoConverter.wgs84ToGrid(point) else { return Grid(nx: 0, ny: 0) }
        return Grid(nx: convertedPoint.x, ny: convertedPoint.y)
    }
}
