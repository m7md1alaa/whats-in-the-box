import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @EnvironmentObject private var themeManager: ThemeManager

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(themeManager.selectedTheme.normalBtnTitleFont)
            .padding()
            .frame(maxWidth: .infinity)
            .background(themeManager.selectedTheme.primaryThemeColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @EnvironmentObject private var themeManager: ThemeManager

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(themeManager.selectedTheme.normalBtnTitleFont)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.clear) // Changed from textBoxColor
            .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.selectedTheme.primaryThemeColor, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
