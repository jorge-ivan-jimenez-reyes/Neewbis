//
//  RecommendationsView.swift
//  neeewwbi
//
//  Created by Jorge Ivan Jimenez Reyes  on 05/12/24.
//

import SwiftUI

struct RecommendationsView: View {
    @State private var recommendations: [RecommendedNews] = []

    var body: some View {
        NavigationView {
            List(recommendations, id: \.id) { news in
                VStack(alignment: .leading) {
                    Text(news.title)
                        .font(.headline)
                    Text(news.summary)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Recomendaciones")
            .onAppear {
                fetchRecommendations()
            }
        }
    }

    func fetchRecommendations() {
        APIService.fetchRecommendations { fetchedRecommendations in
            DispatchQueue.main.async {
                self.recommendations = fetchedRecommendations
            }
        }
    }
}
