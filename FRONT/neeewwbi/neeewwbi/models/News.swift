//
//  news.swift
//  neeewwbi
//
//  Created by Jorge Ivan Jimenez Reyes  on 05/12/24.
//

import Foundation

struct News: Identifiable, Codable {
    let id: Int
    let title: String
    let summary: String
    let content: String
    let published_at: String
    let url: String?
    let categories: [String]
    let keywords: [String]

    static let mock = News(
        id: 1,
        title: "Noticia de ejemplo",
        summary: "Este es un resumen de la noticia.",
        content: "Contenido detallado de la noticia.",
        published_at: "2024-12-04",
        url: "https://example.com",
        categories: ["Tecnología"],
        keywords: ["IA", "Innovación"]
    )
}
