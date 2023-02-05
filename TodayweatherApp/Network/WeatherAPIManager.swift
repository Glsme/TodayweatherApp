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
    
    func requestSomething(date: Date, coordinate: CLLocationCoordinate2D) {
        let point = GeographicPoint(x: coordinate.longitude, y: coordinate.latitude)
        guard let convertedPoint = geoConverter.wgs84ToGrid(point) else { return }
        let grid = Grid(nx: convertedPoint.x, ny: convertedPoint.y)
        let router = WeatherAPIRouter.ultraSrtNcst(date: date, grid: grid)
        
        AF.request(router).responseDecodable(of: UltraSrtNcst.self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                dump(data)
                self.weatherData.removeAll()
                self.weatherData.append(contentsOf: data.response.body.items.item)
            case .failure(let error):
                dump(error)
            }
        }
    }
}
