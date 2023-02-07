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
        let router = WeatherAPIRouter.vilageFcst(date: date, grid: convertGrid(coordinate))
        
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
