import SwiftUI

struct LanguageChangeSheet: View {

    let initialPair: LanguagePair?
    let onConfirm: (LanguagePair) -> Void
    let onReset: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var fromCode: String?
    @State private var toCode: String?

    private let availableLanguages: [LanguageOption] = [
        LanguageOption(code: "en", name: "English"),
        LanguageOption(code: "tr", name: "Turkish"),
        LanguageOption(code: "de", name: "German"),
        LanguageOption(code: "es", name: "Spanish"),
        LanguageOption(code: "fr", name: "French"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Text("Choose languages")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                Text("Tap once to set Source, tap another card to set Target.\nTap again to clear.")
                    .font(.footnote)
                    .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                // Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ],
                    spacing: 12
                ) {
                    ForEach(availableLanguages) { option in
                        let role = roleFor(code: option.code)

                        LanguageCard(
                            option: option,
                            role: role,
                            isDisabled: false,
                            isSelected: role != .none
                        ) {
                            handleTap(code: option.code)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)

                Spacer()

                // Action buttons
                HStack(spacing: 12) {
                    Button {
                        fromCode = nil
                        toCode = nil
                        onReset()
                        dismiss()
                    } label: {
                        Text("Reset")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(AppTheme.Colors.disabled)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .cornerRadius(12)
                    }

                    Button {
                        guard let from = fromCode,
                            let to = toCode,
                            from != to
                        else { return }

                        let pair = LanguagePair(fromCode: from, toCode: to)
                        onConfirm(pair)
                        dismiss()
                    } label: {
                        Text("OK")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(canConfirm ? AppTheme.Colors.progress : AppTheme.Colors.disabled)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .cornerRadius(12)
                    }
                    .disabled(!canConfirm)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .onAppear {
                if let initial = initialPair {
                    fromCode = initial.fromCode
                    toCode = initial.toCode
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var canConfirm: Bool {
        if let from = fromCode, let to = toCode, from != to {
            return true
        }
        return false
    }

    private func roleFor(code: String) -> LanguageRole {
        if code == fromCode {
            return .source
        } else if code == toCode {
            return .target
        } else {
            return .none
        }
    }

    private func handleTap(code: String) {
        if fromCode == nil {
            fromCode = code
        } else if toCode == nil && code != fromCode {
            toCode = code
        } else if fromCode == code {
            fromCode = nil
        } else if toCode == code {
            toCode = nil
        } else {
            toCode = code
        }
    }
}
