//
//  SearchManager.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/2/21.
//

import SwiftUI
import Combine

class SearchManager: ObservableObject {
    @Published var searchText = ""
    @Published var debouncedSearchText = ""
    @Published var isShowingSearch = false {
        didSet {
            if !isShowingSearch {
                searchText = ""
                debouncedSearchText = ""
            }
        }
    }
    
    var subscription: AnyCancellable?
    
    init() {
        subscription = $searchText
            .debounce(for: .seconds(0.2),
                         scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.debouncedSearchText = $0
            }
    }
}
