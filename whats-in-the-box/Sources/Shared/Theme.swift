import SwiftUI
import Combine

/**
 Protocol for themes
 */
protocol ThemeProtocol {
    var largeTitleFont: Font { get }
    var textTitleFont: Font { get }
    var normalBtnTitleFont: Font { get }
    var boldBtnTitleFont: Font { get }
    var bodyTextFont: Font { get }
    var captionTxtFont: Font { get }
    
    var primaryThemeColor: Color { get }
    var secondoryThemeColor: Color { get }
    var affirmBtnTitleColor: Color { get }
    var negativeBtnTitleColor: Color { get }
    var bodyTextColor: Color { get }
    var textBoxColor: Color { get }
}

class ThemeManager: ObservableObject {
    @Published var selectedTheme: ThemeProtocol = Main()
    
    func setTheme(_ theme: ThemeProtocol) {
        selectedTheme = theme
    }
}

/**
 Main Theme
 */
struct Main: ThemeProtocol {
    var largeTitleFont: Font = .system(size: 30, weight: .bold, design: .rounded)
    var textTitleFont: Font = .system(size: 24, weight: .bold, design: .rounded)
    var normalBtnTitleFont: Font = .system(size: 20, weight: .semibold, design: .rounded)
    var boldBtnTitleFont: Font = .system(size: 20, weight: .bold, design: .rounded)
    var bodyTextFont: Font = .system(size: 18, weight: .regular, design: .rounded)
    var captionTxtFont: Font = .system(size: 20, weight: .semibold, design: .rounded)
    
    var primaryThemeColor: Color { return Color("mnPrimaryThemeColor") }
    var secondoryThemeColor: Color { return Color("mnSecondoryThemeColor") }
    var affirmBtnTitleColor: Color { return Color("mnAffirmBtnTitleColor") }
    var negativeBtnTitleColor: Color { return Color("mnNegativeBtnTitleColor") }
    var bodyTextColor: Color { return Color("mnBodyTextColor") }
    var textBoxColor: Color { return Color("mnTextBoxColor") }
}
