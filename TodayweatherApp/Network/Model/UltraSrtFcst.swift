//
//  UltraSrtFcst.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/07.
//

import Foundation

struct UltraSrtFcst: Codable {
    let response: UltraSrtFcstResponse
}

struct UltraSrtFcstResponse: Codable {
    let header: UltraSrtFcstHeader
    let body: UltraSrtFcstBody
}

struct UltraSrtFcstBody: Codable {
    let dataType: String
    let items: UltraSrtFcstItems
    let pageNo, numOfRows, totalCount: Int
}

struct UltraSrtFcstItems: Codable {
    let item: [UltraSrtFcstItem]
}

struct UltraSrtFcstItem: Codable, Hashable {
    let baseDate, baseTime, category, fcstDate: String
    let fcstTime, fcstValue: String
    let nx, ny: Int
}

struct UltraSrtFcstHeader: Codable {
    let resultCode, resultMsg: String
}
