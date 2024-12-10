import SwiftUI

struct SwipeNewsView: View {
    @State private var news: [News] = [
        News(id: 1, title: "El avance de la inteligencia artificial en 2024", summary: "Descubre cómo la IA está transformando industrias y el día a día en todo el mundo.", content: "Detalles sobre IA", published_at: "2024-12-05", url: "https://example.com/ai", categories: ["Tecnología"], keywords: ["IA", "Innovación"]),
        News(id: 2, title: "Exploración espacial: Marte más cerca que nunca", summary: "La NASA revela nuevos planes para llevar humanos a Marte antes de 2030.", content: "Detalles sobre exploración espacial", published_at: "2024-12-04", url: "https://example.com/mars", categories: ["Ciencia"], keywords: ["Marte", "NASA"]),
        News(id: 3, title: "Las 10 mejores aplicaciones móviles de 2024", summary: "Conoce las aplicaciones que están marcando tendencia en este año.", content: "Top 10 apps", published_at: "2024-12-03", url: "https://example.com/apps", categories: ["Tecnología"], keywords: ["Apps", "Innovación"])
    ]
    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        NavigationView {
            ZStack {
                // Fondo degradado para hacer más atractivo el diseño
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    if currentIndex < news.count {
                        ZStack {
                            ForEach((currentIndex..<min(currentIndex + 3, news.count)).reversed(), id: \.self) { index in
                                NewsCard(news: news[index])
                                    .frame(maxWidth: 350, maxHeight: 500)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .offset(x: index == currentIndex ? dragOffset.width : 0,
                                            y: index == currentIndex ? dragOffset.height : 10)
                                    .rotationEffect(index == currentIndex ? .degrees(Double(dragOffset.width / 10)) : .zero)
                                    .scaleEffect(index == currentIndex ? 1.0 : 0.9)
                                    .opacity(index == currentIndex ? 1 : 0.7)
                                    .gesture(
                                        index == currentIndex ?
                                        DragGesture()
                                            .onChanged { value in
                                                dragOffset = value.translation
                                            }
                                            .onEnded { value in
                                                handleSwipe(value: value)
                                            } : nil
                                    )
                                    .animation(.easeInOut(duration: 0.3), value: dragOffset)
                            }
                        }
                        .padding()
                    } else {
                        Text("🎉 ¡Has leído todas las noticias!")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }

                    Spacer()

                    // Indicador de swipe
                    HStack(spacing: 20) {
                        Text("⬅️ Dislike")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        Text("➡️ Like")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 20)
                }
                .padding()
                .navigationTitle("Explorar Noticias")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("📰 Noticias Populares")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    func handleSwipe(value: DragGesture.Value) {
        if value.translation.width > 100 {
            handleLike()
        } else if value.translation.width < -100 {
            handleDislike()
        } else {
            resetPosition()
        }
    }

    func handleLike() {
        animateSwipeAndAdvance(liked: true)
    }

    func handleDislike() {
        animateSwipeAndAdvance(liked: false)
    }

    func animateSwipeAndAdvance(liked: Bool) {
        withAnimation {
            dragOffset = CGSize(width: liked ? 500 : -500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            dragOffset = .zero
        }
    }

    func resetPosition() {
        withAnimation {
            dragOffset = .zero
        }
    }
}

struct SwipeNewsView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeNewsView()
    }
}
