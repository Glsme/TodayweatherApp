//
//  Category.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/06.
//

import Foundation

enum WeatherNetworkType {
    case getUltraSrtNcst    // 초단기 실황 조회
    case getUltraSrtFcst    // 초단기 예보 조회
    case getVilageFcst      // 단기 예보 조회
}

enum Category: String {
    case T1H
    case RN1
    case UUU
    case VVV
    case REH
    case PTY
    case VEC
    case WSD
}
