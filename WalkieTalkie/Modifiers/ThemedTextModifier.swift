//
//  ThemedTextModifier.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct ThemedTextFieldModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .foregroundColor(colorScheme == .dark ? .lightTextColor : .darkTextColor)
            .font(.body)
            .padding(8)
            .cornerRadius(4)
            .overlay(RoundedRectangle(cornerRadius: 4)
                        .stroke(colorScheme == .dark ? Color.lightHighlightColor : Color.darkHighlightColor, lineWidth: 1))
    }
}
