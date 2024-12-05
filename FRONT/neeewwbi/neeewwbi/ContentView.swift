//
//  ContentView.swift
//  neeewwbi
//
//  Created by Jorge Ivan Jimenez Reyes on 05/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if isLoggedIn {
                    // Vista principal después de iniciar sesión
                    Text("Bienvenido a Neeewwbi")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()

                    // Botón para explorar noticias
                    NavigationLink(destination: SwipeNewsView()) {
                        Text("Explorar Noticias")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Botón para ver recomendaciones
                    NavigationLink(destination: RecommendationsView()) {
                        Text("Ver Recomendaciones")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Botón para cerrar sesión
                    Button(action: {
                        isLoggedIn = false
                        username = ""
                        password = ""
                    }) {
                        Text("Cerrar Sesión")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    // Vista de inicio de sesión
                    Text("Iniciar Sesión")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    TextField("Usuario", text: $username)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .autocapitalization(.none)

                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                    Button(action: handleLogin) {
                        Text("Iniciar Sesión")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationTitle(isLoggedIn ? "Inicio" : "Acceso")
        }
    }

    func handleLogin() {
        // Simulación de inicio de sesión. Aquí puedes integrar una API para autenticar al usuario.
        if !username.isEmpty && !password.isEmpty {
            // Realizar autenticación (aquí se puede implementar la lógica de API)
            isLoggedIn = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
