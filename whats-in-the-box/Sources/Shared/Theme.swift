import SwiftUI
internal import Combine
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
    var largeTitleFont: Font = .custom("MartelSans-ExtraBold", size: 30.0)
    var textTitleFont: Font = .custom("MartelSans-ExtraBold", size: 24.0)
    var normalBtnTitleFont: Font = .custom("MartelSans-SemiBold", size: 20.0)
    var boldBtnTitleFont: Font = .custom("MartelSans-Bold", size: 20.0)
    var bodyTextFont: Font = .custom("MartelSans-Light", size: 18.0)
    var captionTxtFont: Font = .custom("MartelSans-SemiBold", size: 20.0)
    
    var primaryThemeColor: Color { return Color("mnPrimaryThemeColor") }
    var secondoryThemeColor: Color { return Color("mnSecondoryThemeColor") }
    var affirmBtnTitleColor: Color { return Color("mnAffirmBtnTitleColor") }
    var negativeBtnTitleColor: Color { return Color("mnNegativeBtnTitleColor") }
    var bodyTextColor: Color { return Color("mnBodyTextColor") }
    var textBoxColor: Color { return Color("mnTextBoxColor") }
}
