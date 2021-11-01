//
//  LoginView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Username")
                .modifier(ThemedTextModifier(style: .title2))
            TextField("user@email.com", text: $dataManager.userName)
                .modifier(ThemedTextFieldModifier())
            
            HStack {
                Spacer()
                Button {
                    dataManager.login()
                } label: {
                    Text("Login")
                }
            }
            
        }
        .frame(width: 300)
        .zIndex(1.0)
        .transition(.opacity)
        .onAppear {
            dataManager.clearData()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(DataManager())
    }
}
