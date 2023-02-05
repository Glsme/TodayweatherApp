//
//  WeatherAPIRouter.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/05.
//

import Foundation

import Alamofire

enum WeatherAPIRouter: URLRequestConvertible {
    case ultraSrtNcst(date: Date, grid: Grid)
    
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd HHmm"
        return f
    }
    
    var baseURL: URL {
        switch self {
        case .ultraSrtNcst:
            return URL(string: EndPoint.ultraSrtNcstURL + "getUltraSrtNcst")!
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders {
        return ["Content-Type": "application/x-www-form-urlencoded", "accept": "application/json"]
    }
    
    var parameters: [String: Any] {
        switch self {
        case .ultraSrtNcst(let date, let grid):
            let dateArray = dateFormatter.string(from: date).split(separator: " ")
            return ["serviceKey": APIKey.encodingKey,
                    "numOfRows": 10,
                    "pageNo": 1,
                    "dataType": "JSON",
                    "base_date": dateArray[0],
                    "base_time": "2000",
                    "nx": grid.nx,
                    "ny": grid.ny]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL
        
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers
        
        return try WeatherURLEncoding().encode(request, with: parameters)
    }
}
