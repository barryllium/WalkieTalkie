//
//  WalkieTalkieApp.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

@main
struct WalkieTalkieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(DataManager())
        }
    }
}
