import SwiftUI

struct SwipeNewsView: View {
    @State private var news: [News] = []
    @State private var currentIndex = 0

    var body: some View {
        VStack {
            if currentIndex < news.count {
                NewsCard(news: news[currentIndex])
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 100 {
                                    handleLike()
                                } else if value.translation.width < -100 {
                                    handleDislike()
                                }
                            }
                    )
            } else {
                Text("No hay más noticias.")
                    .font(.title)
            }
        }
        .onAppear {
            fetchNews()
        }
    }

    func handleLike() {
        saveInteraction(liked: true)
        currentIndex += 1
    }

    func handleDislike() {
        saveInteraction(liked: false)
        currentIndex += 1
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
