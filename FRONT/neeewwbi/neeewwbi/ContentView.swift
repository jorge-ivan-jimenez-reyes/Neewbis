import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Título con efecto de animación de escala y colores dinámicos
                Text("🌟 NewSwipe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 20)
                    .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 5)

                // Botón para explorar noticias
                NavigationLink(destination: SwipeNewsView()) {
                    HStack {
                        Spacer()
                        Text("📖 Explorar Noticias")
                            .font(.headline)
                            .fontWeight(.semibold)
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
                    .cornerRadius(16)
                    .shadow(color: Color.blue.opacity(0.5), radius: 15, x: 0, y: 10)
                    .scaleEffect(1.1) // Leve aumento para destacar
                }
                .hoverEffect(.lift)

                // Botón para recomendaciones
                NavigationLink(destination: RecommendationsView()) {
                    HStack {
                        Spacer()
                        Text("✨ Ver Recomendaciones")
                            .font(.headline)
                            .fontWeight(.semibold)
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
                    .cornerRadius(16)
                    .shadow(color: Color.green.opacity(0.5), radius: 15, x: 0, y: 10)
                    .scaleEffect(1.1)
                }
                .hoverEffect(.lift)

                Spacer()

                // Pie de página con información adicional
                VStack {
                    Text("Desliza y descubre noticias interesantes")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 20)

                    Text("🌐 powered by NewSwipe")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .italic()
                }
                .padding(.bottom, 10)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]),
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
