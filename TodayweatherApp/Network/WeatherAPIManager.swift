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
    
    @Published var ultraSrtNcstData: [UltraSrtNcstItem] = []
    @Published var ultraSrtFcstData: [UltraSrtFcstItem] = []
    @Published var vilageFcstData: [VilageFcstItem] = []
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd HHmm"
        return f
    }()
    
    private let geoConverter = GeoConverter()
    
    private override init() { }
    
    func requestUltraSrtNcst(date: Date, coordinate: CLLocationCoordinate2D) {
        let router = WeatherAPIRouter.ultraSrtNcst(date: date, grid: convertGrid(coordinate))
        
        AF.request(router).responseDecodable(of: UltraSrtNcst.self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                let items = data.response.body.items.item
                self.ultraSrtNcstData.removeAll()
                self.ultraSrtNcstData.append(contentsOf: items)
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    func requestUltraSrtFcst(date: Date, coordinate: CLLocationCoordinate2D) {
        let router = WeatherAPIRouter.ultraSrtFcst(date: date, grid: convertGrid(coordinate))
        
        AF.request(router).responseDecodable(of: UltraSrtFcst.self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                let items = data.response.body.items.item
                self.ultraSrtFcstData.removeAll()
                self.ultraSrtFcstData.append(contentsOf: items)
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    func requestVilageFcst(date: Date, coordinate: CLLocationCoordinate2D) {
        let convertedDate: Date = convertVilageFcstDate(date)
        let router = WeatherAPIRouter.vilageFcst(date: convertedDate, grid: convertGrid(coordinate))
        
        AF.request(router).responseDecodable(of: VilageFcst.self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                let items = data.response.body.items.item
                self.vilageFcstData.removeAll()
                self.vilageFcstData.append(contentsOf: items)
            case .failure(let error):
                dump(error)
                print(error.localizedDescription)
            }
        }
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
        
        return dateFormatter.date(from: array[0] + " \(hour)") ?? Date()
    }
    
    private func convertGrid(_ coordinate: CLLocationCoordinate2D) -> Grid {
        let point = GeographicPoint(x: coordinate.longitude, y: coordinate.latitude)
        guard let convertedPoint = geoConverter.wgs84ToGrid(point) else { return Grid(nx: 0, ny: 0) }
        return Grid(nx: convertedPoint.x, ny: convertedPoint.y)
    }
    
//    private func convertCategory(_ item: Item) -> Item {
//        let categoryType = Category(rawValue: item.category)
//        var category: String = ""
//
//        switch categoryType {
//        case .T1H:
//            category = "기온"
//        case .RN1:
//            category = "1시간 강수량"
//        case .UUU:
//            category = "동서바람성분"
//        case .VVV:
//            category = "남북바람성분"
//        case .REH:
//            category = "습도"
//        case .PTY:
//            category = "강수 형태"
//        case .VEC:
//            category = "풍향"
//        case .WSD:
//            category = "풍속"
//        case .none:
//            break
//        }
//
//        return Item(baseDate: item.baseDate,
//             baseTime: item.baseTime,
//             category: category,
//             nx: item.nx,
//             ny: item.ny,
//             obsrValue: item.obsrValue)
//    }
}
