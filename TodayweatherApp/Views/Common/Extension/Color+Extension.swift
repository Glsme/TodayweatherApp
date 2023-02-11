//
//  Color+Extension.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/11.
//

import SwiftUI

extension Color {
    init(r: Double, g: Double, b: Double) {
        self.init(red: r / 255, green: g / 255, blue: b / 255)
    }
}
