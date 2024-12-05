//
//  APIService.swift
//  neeewwbi
//
//  Created by Jorge Ivan Jimenez Reyes  on 05/12/24.
//

import Foundation

class APIService {
    static func fetchNews(completion: @escaping ([News]) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/news/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error al obtener noticias: \(error)")
                return
            }

            if let data = data {
                do {
                    let news = try JSONDecoder().decode([News].self, from: data)
                    completion(news)
                } catch {
                    print("Error al decodificar noticias: \(error)")
                }
            }
        }.resume()
    }

    static func saveInteraction(newsId: Int, liked: Bool) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/user-interaction/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let interaction = UserInteraction(userId: 1, newsId: newsId, liked: liked)
        guard let data = try? JSONEncoder().encode(interaction) else { return }

        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error al guardar interacción: \(error)")
            }
        }.resume()
    }
}
