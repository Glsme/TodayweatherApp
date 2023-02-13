//
//  TextModifier.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import SwiftUI

struct TempTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(Fonts.bold.rawValue, size: 16))
    }
}

struct TimeTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(Fonts.bold.rawValue, size: 14))
            .lineLimit(50)
            .opacity(0.5)
            .fixedSize(horizontal: true, vertical: true)
    }
}
