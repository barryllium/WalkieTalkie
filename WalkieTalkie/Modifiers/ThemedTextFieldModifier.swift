//
//  ThemedTextFieldModifier.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct ThemedTextModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var style: Font

    func body(content: Content) -> some View {
        content
            .foregroundColor(colorScheme == .dark ? .lightTextColor : .darkTextColor)
            .font(style)
    }
}
