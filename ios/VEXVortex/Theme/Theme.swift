import SwiftUI

/// VEXVortex's color system: warm, minimal neutrals (paper/charcoal) with a
/// single emerald accent — same structure as Claude's palette, with emerald
/// standing in for Claude's clay/orange. Values live in Assets.xcassets so
/// they resolve per light/dark appearance automatically; this file just
/// gives them stable names to reference from views.
///
/// `red`/`blue` in match displays are intentionally left as system colors —
/// they denote actual VEX alliance colors (game data), not brand styling.
extension Color {
    static let appBackground = Color("Background")
    static let appSurface = Color("Surface")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let appDivider = Color("AppDivider")
}

/// Applies the flat, minimal list treatment used throughout the app:
/// plain style, custom background, hairline dividers instead of the default
/// system grouped-list chrome.
struct MinimalListStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .listRowSeparatorTint(Color.appDivider)
    }
}

extension View {
    func minimalListStyle() -> some View {
        modifier(MinimalListStyle())
    }
}
