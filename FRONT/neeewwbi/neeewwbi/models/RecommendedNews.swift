//
//  RecommendedNews.swift
//  neeewwbi
//
//  Created by Jorge Ivan Jimenez Reyes  on 05/12/24.
//

struct RecommendedNews: Decodable {
    let id: Int
    let title: String
    let summary: String
}

struct RecommendationsResponse: Decodable {
    let recommendations: [RecommendedNews]
}
