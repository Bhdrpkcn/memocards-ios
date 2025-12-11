import SwiftUI

struct LanguageSelectionView: View {

    let step: StartStep
    let availableLanguages: [LanguageOption]

    let selectedFromCode: String?
    let selectedToCode: String?

    let onSelectFrom: (String) -> Void
    let onSelectTo: (String) -> Void

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ],
            spacing: 12
        ) {
            ForEach(availableLanguages) { option in
                let isDisabled = disabledCodes.contains(option.code)
                let role = languageRole(for: option)
                let isSelected = isLanguageSelected(option)

                LanguageCard(
                    option: option,
                    role: role,
                    isDisabled: isDisabled,
                    isSelected: isSelected
                ) {
                    guard !isDisabled else { return }
                    handleTap(option)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    // MARK: - Logic

    private var disabledCodes: [String] {
        switch step {
        case .chooseFromLanguage:
            return []
        case .chooseToLanguage(let from):
            return [from]
        case .chooseContent:
            return []
        }
    }

    private func handleTap(_ option: LanguageOption) {
        switch step {
        case .chooseFromLanguage:
            onSelectFrom(option.code)
        case .chooseToLanguage:
            onSelectTo(option.code)
        case .chooseContent:
            break
        }
    }

    private func languageRole(for option: LanguageOption) -> LanguageRole {
        let code = option.code
        let from = selectedFromCode
        let to = selectedToCode

        switch (code == from, code == to) {
        case (true, true):
            return .both
        case (true, false):
            return .source
        case (false, true):
            return .target
        default:
            return .none
        }
    }

    private func isLanguageSelected(_ option: LanguageOption) -> Bool {
        switch step {
        case .chooseFromLanguage:
            return selectedFromCode == option.code
        case .chooseToLanguage:
            return selectedToCode == option.code
        case .chooseContent:
            return false
        }
    }
}
