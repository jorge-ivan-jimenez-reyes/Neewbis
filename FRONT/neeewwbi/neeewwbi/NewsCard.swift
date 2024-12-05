//
//  NewsCard.swift
//  neeewwbi
//
//  Created by Jorge Ivan Jimenez Reyes  on 05/12/24.
//

import SwiftUI

struct NewsCard: View {
    var news: News

    var body: some View {
        VStack(alignment: .leading) {
            Text(news.title)
                .font(.title)
                .padding(.bottom, 5)
            Text(news.summary)
                .font(.body)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, 20)
    }
}

struct NewsCard_Previews: PreviewProvider {
    static var previews: some View {
        NewsCard(news: News.mock)
    }
}
