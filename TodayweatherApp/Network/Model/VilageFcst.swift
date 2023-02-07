//
//  VilageFcst.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/07.
//

import Foundation

struct VilageFcst: Codable {
    let response: VilageFcstResponse
}

struct VilageFcstResponse: Codable {
    let header: VilageFcstHeader
    let body: VilageFcstBody
}

struct VilageFcstBody: Codable {
    let dataType: String
    let items: VilageFcstItems
    let pageNo, numOfRows, totalCount: Int
}

struct VilageFcstItems: Codable {
    let item: [VilageFcstItem]
}

struct VilageFcstItem: Codable, Hashable {
    let baseDate, baseTime, category, fcstDate: String
    let fcstTime, fcstValue: String
    let nx, ny: Int
}

struct VilageFcstHeader: Codable {
    let resultCode, resultMsg: String
}
