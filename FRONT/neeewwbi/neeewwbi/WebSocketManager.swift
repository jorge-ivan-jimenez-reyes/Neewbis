import Foundation

class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://192.168.0.16:8002/ws/recommendations/")!
    var onMessageReceived: (([News]) -> Void)?

    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        listenForMessages()
    }

    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("[ERROR] WebSocket error: \(error.localizedDescription)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("[INFO] Mensaje recibido: \(text)")
                    self?.handleMessage(text: text)
                default:
                    print("[INFO] Tipo de mensaje no manejado")
                }
            }
            self?.listenForMessages() // Continuar escuchando
        }
    }

    private func handleMessage(text: String) {
        guard let data = text.data(using: .utf8) else { return }
        do {
            let decoder = JSONDecoder()
            let news = try decoder.decode([News].self, from: data)
            onMessageReceived?(news) // Notificar a la vista con las nuevas noticias
        } catch {
            print("[ERROR] Error al decodificar noticias: \(error.localizedDescription)")
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
