//
//  ContentView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    
    @ViewBuilder
    var body: some View {
        if dataManager.loggedInUser == nil {
            LoginView()
        } else {
            ConversationsView()
                .alert(isPresented: $dataManager.isShowingAlert) {
                    Alert(title: Text("Error"),
                          message: Text("There was an error fetching recordings. Please try again"),
                          dismissButton: .default(Text("OK")))
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(DataManager())
    }
}
