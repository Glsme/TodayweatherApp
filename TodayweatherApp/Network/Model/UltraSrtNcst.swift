//
//  UltraSrtNcst.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/05.
//

import Foundation

struct UltraSrtNcst: Codable {
    var response: Response
}

struct Response: Codable {
    var header: Header
    var body: Body
}

struct Body: Codable {
    var dataType: String
    var items: Items
    var pageNo, numOfRows, totalCount: Int
}

struct Items: Codable {
    var item: [Item]
}

struct Item: Codable, Hashable {
    var baseDate, baseTime, category: String
    var nx, ny: Double
    var obsrValue: String
}

struct Header: Codable {
    var resultCode, resultMsg: String
}
