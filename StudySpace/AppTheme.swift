//
//  AppTheme.swift
//  StudySpace
//
//  Created by Risini Senara on 2026-10-09.
//

import SwiftUI


enum AppTheme {
    static let background = Color(uiColor: .systemBackground)
    static let lilac = Color(hex: "E6D7FF")
    static let lightGrey = Color(uiColor: .secondarySystemBackground)
    static let text = Color(uiColor: .label)

    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let cardBackground = Color(uiColor: .secondarySystemBackground)
}


// Converts a hexadecimal colour into a SwiftUI Color
extension Color {
    init(hex: String) {
        let value = UInt64(hex, radix: 16) ?? 0

        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }
}

