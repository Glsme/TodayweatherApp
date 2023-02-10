//
//  TextModifier.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/10.
//

import SwiftUI

struct BodyTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(Fonts.bold.rawValue, size: 16))
    }
}
