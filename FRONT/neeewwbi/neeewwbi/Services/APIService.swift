import Foundation

class APIService {
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60 // Tiempo de espera para la solicitud en segundos
        config.timeoutIntervalForResource = 120 // Tiempo de espera para la respuesta completa
        return URLSession(configuration: config)
    }()

    // Token fijo
    static let authToken = "7476a40a5aee3a0d5a17bd2e29676b6182d4f893"

    // Obtener noticias
    static func fetchNews(completion: @escaping ([News]) -> Void) {
        guard let url = URL(string: "http://192.168.137.244:8002/api/news/") else {
            print("[ERROR] URL no válida")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(authToken)", forHTTPHeaderField: "Authorization")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[ERROR] Error al obtener noticias: \(error.localizedDescription)")
                completion([])
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("[DEBUG] Código de respuesta HTTP: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("[ERROR] Respuesta no exitosa. Código: \(httpResponse.statusCode)")
                    completion([])
                    return
                }
            }

            guard let data = data else {
                print("[ERROR] No se recibió data del servidor.")
                completion([])
                return
            }

            do {
                let news = try JSONDecoder().decode([News].self, from: data)
                print("[DEBUG] Noticias decodificadas exitosamente: \(news.count) artículos.")
                completion(news)
            } catch {
                print("[ERROR] Error al decodificar noticias: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }

    // Obtener recomendaciones
    static func fetchRecommendations(completion: @escaping ([RecommendedNews]) -> Void) {
        guard let url = URL(string: "http://192.168.137.244:8002/api/recommendations/content-based/") else {
            print("[ERROR] URL no válida")
            completion([]) // Devuelve una lista vacía
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token 7476a40a5aee3a0d5a17bd2e29676b6182d4f893", forHTTPHeaderField: "Authorization")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[ERROR] Error al obtener recomendaciones: \(error.localizedDescription)")
                completion([]) // Devuelve una lista vacía
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("[DEBUG] Código de respuesta HTTP: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("[ERROR] Respuesta no exitosa. Código: \(httpResponse.statusCode)")
                    completion([]) // Devuelve una lista vacía
                    return
                }
            }

            guard let data = data else {
                print("[ERROR] No se recibió data del servidor.")
                completion([]) // Devuelve una lista vacía
                return
            }

            do {
                let response = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                print("[DEBUG] Recomendaciones decodificadas exitosamente.")
                completion(response.recommendations)
            } catch {
                print("[ERROR] Error al decodificar recomendaciones: \(error.localizedDescription)")
                completion([]) // Devuelve una lista vacía si hay error
            }
        }.resume()
    }

    // Guardar interacciones
    static func saveInteraction(newsId: Int, liked: Bool) {
        guard let url = URL(string: "http://192.168.137.244:8002/api/user-interaction/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(authToken)", forHTTPHeaderField: "Authorization")

        let interaction = [
            "user_id": 1, // ID fijo del usuario
            "news_id": newsId,
            "liked": liked
        ] as [String: Any]

        guard let data = try? JSONSerialization.data(withJSONObject: interaction, options: []) else {
            print("[ERROR] Error al codificar interacción")
            return
        }

        print("[DEBUG] Datos enviados al servidor: \(String(data: data, encoding: .utf8) ?? "Error al convertir a String")")

        request.httpBody = data

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[ERROR] Error al guardar interacción: \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse {
                print("[DEBUG] Código de respuesta al guardar interacción: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 201 {
                    print("[INFO] Interacción guardada con éxito")
                    if let data = data {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                print("[DEBUG] Respuesta del servidor: \(jsonResponse)")
                            }
                        } catch {
                            print("[ERROR] Error al decodificar la respuesta: \(error.localizedDescription)")
                        }
                    }
                } else {
                    print("[ERROR] Error al guardar interacción. Código: \(httpResponse.statusCode)")
                    if let data = data {
                        print("[DEBUG] Respuesta del servidor: \(String(data: data, encoding: .utf8) ?? "No se pudo convertir la respuesta")")
                    }
                }
            }
        }.resume()
    }
}
