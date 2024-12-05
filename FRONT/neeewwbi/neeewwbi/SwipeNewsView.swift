import SwiftUI

struct SwipeNewsView: View {
    @State private var news: [News] = []
    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    @State private var animateOpacity: Bool = true

    var body: some View {
        NavigationView {
            VStack {
                if currentIndex < news.count {
                    ZStack {
                        // Mostrar solo un rango limitado de noticias en la pila para evitar que se acumulen
                        ForEach((currentIndex..<min(currentIndex + 3, news.count)).reversed(), id: \.self) { index in
                            NewsCard(news: news[index])
                                .frame(maxWidth: 350, maxHeight: 500)
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
                    Text("No hay más noticias.")
                        .font(.title)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Explorar Noticias")
            .onAppear {
                fetchNews()
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
            saveInteraction(liked: liked)
            currentIndex += 1
            dragOffset = .zero
        }
    }

    func resetPosition() {
        withAnimation {
            dragOffset = .zero
        }
    }

    func saveInteraction(liked: Bool) {
        APIService.saveInteraction(newsId: news[currentIndex].id, liked: liked)
    }

    func fetchNews() {
        APIService.fetchNews { fetchedNews in
            DispatchQueue.main.async {
                self.news = fetchedNews
            }
        }
    }
}

struct SwipeNewsView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeNewsView()
    }
}
