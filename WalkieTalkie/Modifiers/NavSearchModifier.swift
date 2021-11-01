//
//  NavSearchModifier.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct NavSearchModifier: ViewModifier {
    @Binding var searchText: String

    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
        } else {
            content
        }
    }
}
