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
    var isSubText = false

    func body(content: Content) -> some View {
        let lightColor: Color = isSubText ? .lightHighlightColor : .lightTextColor
        let darkColor: Color = isSubText ? .darkHighlightColor : .darkTextColor
        
        return content
            .foregroundColor(colorScheme == .dark ? lightColor : darkColor)
            .font(style)
    }
}
