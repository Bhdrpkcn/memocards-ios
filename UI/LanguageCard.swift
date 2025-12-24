import SwiftUI

enum LanguageRole {
    case none
    case source
    case target

    var label: String? {
        switch self {
        case .none: return nil
        case .source: return "Source"
        case .target: return "Target"
        }
    }

    var tintColor: Color {
        switch self {
        case .none: return .clear
        case .source: return AppTheme.Colors.progress
        case .target: return AppTheme.Colors.success
        }
    }
}

struct LanguageCard: View {

    let option: LanguageOption
    let role: LanguageRole
    let isDisabled: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                // MAIN CARD
                VStack(spacing: 6) {
                    Text(option.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity, minHeight: 34)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            borderColor.opacity(0.7),
                            lineWidth: isSelected ? 4.5 : 1.5
                        )
                )
                .scaleEffect(isSelected ? 1.02 : 1.0)
                .opacity(isDisabled ? 0.45 : 1.0)
                .animation(
                    .spring(response: 0.25, dampingFraction: 0.85),
                    value: isSelected
                )

                // BADGE OVERLAY
                if isSelected, let label = role.label {
                    Text(label.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundColor(AppTheme.Colors.progress.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(AppTheme.Colors.screenBackground.opacity(0.9))
                                .shadow(radius: 1)
                        )
                        .overlay(
                            Capsule()
                                .stroke(role.tintColor.opacity(0.6), lineWidth: 1)
                        )
                        .offset(y: -12)
                        .transition(.scale.combined(with: .opacity))
                        .animation(
                            .spring(response: 0.25, dampingFraction: 0.85),
                            value: isSelected
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var backgroundColor: Color {
        if isDisabled {
            return Color(AppTheme.Colors.disabled)
        }
        if isSelected {
            return role.tintColor.opacity(0.30)
        }
        return AppTheme.Colors.screenSecBackground
    }

    private var borderColor: Color {
        if isSelected {
            return role.tintColor
        }
        return AppTheme.Colors.disabled
    }
}
