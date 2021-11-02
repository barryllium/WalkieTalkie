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
        VStack(alignment: .leading, spacing: 16) {
            Text("Username")
                .modifier(ThemedTextModifier(style: .title2))
            TextField("user@email.com", text: $dataManager.userName, onCommit: {
                dataManager.login()
            })
                .autocapitalization(.none)
                .modifier(ThemedTextFieldModifier())
            
            HStack {
                Spacer()
                Button {
                    dataManager.login()
                } label: {
                    Text("Login")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.appBlue)
                        .cornerRadius(8)
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
