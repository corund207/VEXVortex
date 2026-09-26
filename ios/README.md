# ios/ — VEXVortex native iOS app

Native Swift/SwiftUI client for VEX Robotics stats.

```text
ios/
├── project.yml            # XcodeGen spec — generates VEXVortex.xcodeproj (not committed)
├── VEXVortex/
│   ├── App/                # Entry point (VEXVortexApp), RootView (TabView), AppConfig
│   ├── Theme/               # Theme.swift — color system + minimalListStyle()
│   ├── Features/           # Teams, Events, Favorites (SwiftUI views + view models)
│   ├── Networking/         # SupabaseClient (URLSession + PostgREST), APIError
│   ├── Models/              # Codable DTOs matching supabase/migrations
│   ├── Persistence/         # FavoritesStore (UserDefaults), CacheStore (disk, stale-aware)
│   └── Resources/          # Assets.xcassets (incl. AppIcon, color system), Info.plist, xcconfig
├── VEXVortexTests/          # Unit tests (DTO decoding, FavoritesStore)
└── VEXVortexUITests/        # Launch smoke test
```

## Why the `.xcodeproj` isn't committed

This project is developed without local macOS/Xcode access, so a hand-written
`.pbxproj` can't be opened here to validate. Instead, `project.yml` (read by
[XcodeGen](https://github.com/yonaskolb/XcodeGen)) is the source of truth, and
`VEXVortex.xcodeproj` is regenerated deterministically wherever Xcode is
available — locally or in CI. This also avoids `.pbxproj` merge conflicts.

## Local dev (on a Mac)

```bash
brew install xcodegen
cd ios
cp VEXVortex/Resources/Config/Local.xcconfig.example VEXVortex/Resources/Config/Local.xcconfig
# edit Local.xcconfig with your dev Supabase project's SUPABASE_HOST / SUPABASE_ANON_KEY
xcodegen generate
open VEXVortex.xcodeproj
```

`Local.xcconfig` is gitignored — never commit real values.

## No Mac available (Windows/Linux)

You cannot run Xcode or XcodeGen locally. Use [Codemagic](../codemagic.yaml):
it installs XcodeGen, generates the project, injects `SUPABASE_URL` /
`SUPABASE_ANON_KEY` from Codemagic environment variables, builds, signs, and
produces an `.ipa` — install that on your iPhone via TestFlight, or sideload
it (AltStore/SideStore, or Codemagic's ad-hoc `.ipa` + a sideloading tool)
if you're not yet in TestFlight.

## Design system

Minimal, Claude-style warm-neutral palette (paper/charcoal, not pure white/black) with a single emerald accent standing in for Claude's clay/orange:

| Token (`Assets.xcassets`) | Light | Dark | Use |
|---|---|---|---|
| `AccentColor` | `#0E7A5F` | `#34D399` | Favorited stars, links, tab tint, ranks — the *only* brand color |
| `Background` | `#FAF9F5` | `#262624` | Screen/list background |
| `Surface` | `#F0EEE6` | `#30302E` | Detail-view rows, grouped sections |
| `TextPrimary` | `#1F1E1D` | `#F5F4EF` | Primary text |
| `TextSecondary` | `#6B6A66` | `#A8A69E` | Secondary/meta text |
| `AppDivider` | `#E8E6DD` | `#3D3B37` | Hairline separators |

Reference these via `Color.appBackground`, `Color.textPrimary`, etc. (`Theme.swift`), and apply `.minimalListStyle()` to any `List` for the flat, plain-style, custom-divider treatment used throughout. Match displays intentionally keep system red/blue for VEX alliance colors — that's game data, not brand styling, so it's exempt from the palette.

## Rules

- Supabase `anon` key only in the bundle. `service_role` never ships.
- Every stat links to its source; cached rows show stale timestamps (`CacheStore`).
- Secrets via `Local.xcconfig` locally and Codemagic variables in CI — never in `Debug.xcconfig` / `Release.xcconfig` / `Shared.xcconfig`, which are committed.
- New UI reuses the color tokens above — no ad hoc hex values or unmodified `.secondary`/system colors in views.

## Known gaps (not yet implemented)

- Supabase Auth (favorites are local-only for now, per the roadmap).
- Season-long per-team trend aggregates / OPR-DPR-style stats.
