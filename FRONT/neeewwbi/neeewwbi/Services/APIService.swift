import Foundation

class APIService {
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30 // Tiempo de espera para la solicitud en segundos
        config.timeoutIntervalForResource = 60 // Tiempo de espera para la respuesta completa
        return URLSession(configuration: config)
    }()
    
    static func fetchNews(completion: @escaping ([News]) -> Void) {
        guard let url = URL(string: "http://192.168.137.244:8002/api/news/") else {
            print("[ERROR] URL no válida")
            completion([]) // Devuelve una lista vacía para evitar bloqueos
            return
        }

        print("[DEBUG] Intentando obtener noticias desde: \(url.absoluteString)")

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("[ERROR] Error al obtener noticias: \(error.localizedDescription)")
                print("[DEBUG] Asegúrate de que el servidor esté activo y accesible.")
                completion([]) // Devuelve una lista vacía en caso de error
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("[DEBUG] Código de respuesta HTTP: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("[ERROR] Respuesta no exitosa. Código: \(httpResponse.statusCode)")
                    completion([]) // Devuelve una lista vacía si no es 200
                    return
                }
            }

            guard let data = data else {
                print("[ERROR] No se recibió data del servidor.")
                completion([]) // Devuelve una lista vacía
                return
            }

            print("[DEBUG] Data recibida: \(String(data: data, encoding: .utf8) ?? "No se pudo decodificar la data en texto.")")

            do {
                let news = try JSONDecoder().decode([News].self, from: data)
                print("[DEBUG] Noticias decodificadas exitosamente: \(news.count) artículos.")
                completion(news)
            } catch {
                print("[ERROR] Error al decodificar noticias: \(error.localizedDescription)")
                print("[DEBUG] Verifica el formato de los datos devueltos por la API.")
                completion([]) // Devuelve una lista vacía si hay un error al decodificar
            }
        }.resume()
    }

    static func saveInteraction(newsId: Int, liked: Bool) {
        guard let url = URL(string: "http://192.168.137.244:8002/api/user-interaction/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Estructura de datos que se enviará al backend
        let interaction = [
            "user_id": 1,
            "news_id": newsId,
            "liked": liked
        ] as [String : Any]

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
                    // Decodificar la respuesta si es necesario
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
