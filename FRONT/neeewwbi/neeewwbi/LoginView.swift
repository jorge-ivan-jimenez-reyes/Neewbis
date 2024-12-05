import SwiftUI

struct LoginView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Bienvenido, Jorge Jiménez")
                    .font(.title)

                NavigationLink(destination: ContentView()) {
                    Text("Continuar")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
