import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Bienvenido a News Explorer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)

                NavigationLink(destination: SwipeNewsView()) {
                    HStack {
                        Spacer()
                        Text("Explorar Noticias")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                }

                NavigationLink(destination: RecommendationsView()) {
                    HStack {
                        Spacer()
                        Text("Ver Recomendaciones")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.teal]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 5)
                }

                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationTitle("Inicio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
