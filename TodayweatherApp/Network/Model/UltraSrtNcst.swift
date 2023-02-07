//
//  UltraSrtNcst.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/05.
//

import Foundation

struct UltraSrtNcst: Codable {
    var response: UltraSrtNcstResponse
}

struct UltraSrtNcstResponse: Codable {
    var header: UltraSrtNcstHeader
    var body: UltraSrtNcstBody
}

struct UltraSrtNcstBody: Codable {
    var dataType: String
    var items: UltraSrtNcstItems
    var pageNo, numOfRows, totalCount: Int
}

struct UltraSrtNcstItems: Codable {
    var item: [UltraSrtNcstItem]
}

struct UltraSrtNcstItem: Codable, Hashable {
    var baseDate, baseTime, category: String
    var nx, ny: Double
    var obsrValue: String
}

struct UltraSrtNcstHeader: Codable {
    var resultCode, resultMsg: String
}
