import Foundation

struct LanguageService {

    func fetchLanguages() async throws -> [LanguageOption] {
        let path = "languages"
        let dtos = try await APIConfig.client.request([LanguageDTO].self, path)

        return dtos.map { dto in
            LanguageOption(code: dto.code, name: dto.name)
        }
    }
}
