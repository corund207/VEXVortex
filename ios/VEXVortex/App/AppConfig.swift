import Foundation

/// Resolves Supabase connection details injected via `Info.plist` (which in
/// turn come from xcconfig — see `Resources/Config/Shared.xcconfig`).
///
/// Only the `anon` key ever lives here. `service_role` must never be added
/// to this type, Info.plist, or any xcconfig in this target.
struct AppConfig {
    let supabaseURL: URL
    let supabaseAnonKey: String
    let environment: String

    static let current: AppConfig = {
        guard
            let info = Bundle.main.infoDictionary,
            let host = info["SUPABASE_HOST"] as? String, !host.isEmpty,
            let anonKey = info["SUPABASE_ANON_KEY"] as? String, !anonKey.isEmpty,
            let url = URL(string: "https://\(host)")
        else {
            preconditionFailure("""
                Missing or invalid SUPABASE_HOST / SUPABASE_ANON_KEY.
                For local builds: copy ios/VEXVortex/Resources/Config/Local.xcconfig.example \
                to Local.xcconfig and fill in your dev project's values.
                For CI: these come from Codemagic environment variables (see codemagic.yaml).
                """)
        }
        let environment = info["APP_ENV"] as? String ?? "development"
        return AppConfig(supabaseURL: url, supabaseAnonKey: anonKey, environment: environment)
    }()
}
