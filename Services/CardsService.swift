import Foundation
import SwiftUI

protocol CardsServiceProtocol {
    func loadCards() -> [MemoCard]
}

final class LocalJSONCardsService: CardsServiceProtocol {

    private struct MemoCardDTO: Decodable {
        let id: String
        let text: String
        let text_translate: String
    }

    func loadCards() -> [MemoCard] {
        guard let url = Bundle.main.url(forResource: "cards", withExtension: "json") else {
            print("⚠️ cards.json not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let dtos = try JSONDecoder().decode([MemoCardDTO].self, from: data)

            let palette: [Color] = [
                Color(red: 0.89, green: 0.49, blue: 0.36),
                Color(red: 0.98, green: 0.76, blue: 0.44),
                Color(red: 0.58, green: 0.82, blue: 0.62),
                Color(red: 0.44, green: 0.72, blue: 0.84),
                Color(red: 0.64, green: 0.56, blue: 0.87),
            ]

            return dtos.enumerated().map { index, dto in
                MemoCard(
                    id: dto.id,
                    text: dto.text,
                    textTranslate: dto.text_translate,
                    color: palette[index % palette.count]
                )
            }
        } catch {
            print("⚠️ Failed to decode cards.json: \(error)")
            return []
        }
    }
}
