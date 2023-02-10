//
//  VilageFcstData.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import Foundation

struct HourWeather: Hashable {
    var date: String
    var time: String
    var img: String
    var temp: String
    var UUID: String
    
    init(date: String, time: String, img: String, temp: String, UUID: String) {
        self.date = date
        self.time = time
        self.img = img
        self.temp = temp
        self.UUID = UUID
    }
    
    init() {
        self.date = ""
        self.time = ""
        self.img = ""
        self.temp = ""
        self.UUID = ""
    }
}
