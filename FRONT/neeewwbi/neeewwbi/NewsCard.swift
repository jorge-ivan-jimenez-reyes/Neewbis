import SwiftUI

struct NewsCard: View {
    var news: News

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Título de la noticia
            Text(news.title)
                .font(.headline) // Tamaño de fuente más consistente
                .multilineTextAlignment(.leading)
                .lineLimit(3) // Limita a 3 líneas
                .truncationMode(.tail) // Muestra puntos suspensivos si es demasiado largo
                .padding(.bottom, 5)

            // Resumen de la noticia
            Text(news.summary)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(4) // Limita a 4 líneas
                .truncationMode(.tail)

            Spacer()

            // Enlace para leer más
            if let url = news.url, let validURL = URL(string: url) {
                Link("Leer más", destination: validURL)
                    .font(.callout)
                    .foregroundColor(.blue)
                    .padding(.top, 10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, 20)
        .frame(maxWidth: 350, maxHeight: 500) // Tamaño consistente
    }
}

struct NewsCard_Previews: PreviewProvider {
    static var previews: some View {
        NewsCard(news: News.mock) // Usa un mock para probar
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
