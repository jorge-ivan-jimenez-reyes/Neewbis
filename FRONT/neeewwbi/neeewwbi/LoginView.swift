//
//  LoginView.swift
//  neeewwbi
//
//  Created by Jorge Ivan Jimenez Reyes  on 05/12/24.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: loginUser) {
                    Text("Login")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if isLoggedIn {
                    NavigationLink(destination: SwipeNewsView()) {
                        Text("Ir a Noticias")
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationTitle("Login")
        }
    }

    func loginUser() {
        APIService.loginUser(username: username, password: password) { success in
            DispatchQueue.main.async {
                self.isLoggedIn = success
            }
        }
    }
}
