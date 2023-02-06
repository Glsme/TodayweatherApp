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
    
    @Published var weatherData: [Item] = []
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd HHmm"
        return f
    }()
    
    private let geoConverter = GeoConverter()
    
    private override init() { }
    
    func requestUltraSrtNcst(date: Date, coordinate: CLLocationCoordinate2D) {
        let point = GeographicPoint(x: coordinate.longitude, y: coordinate.latitude)
        guard let convertedPoint = geoConverter.wgs84ToGrid(point) else { return }
        let grid = Grid(nx: convertedPoint.x, ny: convertedPoint.y)
        let router = WeatherAPIRouter.ultraSrtNcst(date: date, grid: grid)
        
        AF.request(router).responseDecodable(of: UltraSrtNcst.self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                let items = data.response.body.items.item
                self.weatherData.removeAll()
                self.weatherData.append(contentsOf: self.convertItems(.ultraSrtNcst, data: items))
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    private func convertItems(_ networkType: WeatherNetworkType, data: [Item]) -> [Item] {
        var array: [Item] = []
        switch networkType {
        case .ultraSrtNcst:
            for num in 0..<data.count {
                array.append(convertItem(data[num]))
            }
        }
        
        return array
    }
    
    private func convertItem(_ item: Item) -> Item {
        let categoryType = UltraSrtNcstCategory(rawValue: item.category)
        var category: String = ""
        
        switch categoryType {
        case .T1H:
            category = "기온"
        case .RN1:
            category = "1시간 강수량"
        case .UUU:
            category = "동서바람성분"
        case .VVV:
            category = "남북바람성분"
        case .REH:
            category = "습도"
        case .PTY:
            category = "강수 형태"
        case .VEC:
            category = "풍향"
        case .WSD:
            category = "풍속"
        case .none:
            break
        }
        
        return Item(baseDate: item.baseDate,
             baseTime: item.baseTime,
             category: category,
             nx: item.nx,
             ny: item.ny,
             obsrValue: item.obsrValue)
    }
}
