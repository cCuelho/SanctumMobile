# Sanctum Mobile — Navigation Map

Generated: 2026-07-06T12:16:17.074601
Pages: 27 · Edges: 24 · Failures: 9

## Pages

### Connect Sanctum

![Connect Sanctum](screenshots/000_auth.png)

| Field | Value |
| --- | --- |
| **ID** | `auth` |
| **Route** | `/auth` |
| **Screenshot** | `screenshots/000_auth.png` |
| **Reached via** | Splash timeout → unauthenticated |
| **Visible hints** | Connect Sanctum, Continue |

### Onboarding — Welcome

![Onboarding — Welcome](screenshots/001_onboarding_welcome.png)

| Field | Value |
| --- | --- |
| **ID** | `onboarding_welcome` |
| **Route** | `/onboarding` |
| **Screenshot** | `screenshots/001_onboarding_welcome.png` |
| **Reached via** | Auth → New user |
| **Visible hints** | Welcome to Sanctum, Next |

### Onboarding — Choose Focus

![Onboarding — Choose Focus](screenshots/002_onboarding_focus.png)

| Field | Value |
| --- | --- |
| **ID** | `onboarding_focus` |
| **Route** | `/onboarding` |
| **Screenshot** | `screenshots/002_onboarding_focus.png` |
| **Reached via** | Onboarding welcome → Next |
| **Visible hints** | Sleep Optimization, Rehabilitation |

### Onboarding — Protocols

![Onboarding — Protocols](screenshots/003_onboarding_protocols.png)

| Field | Value |
| --- | --- |
| **ID** | `onboarding_protocols` |
| **Route** | `/onboarding` |
| **Screenshot** | `screenshots/003_onboarding_protocols.png` |
| **Reached via** | Focus step → Next |

### Onboarding — Device

![Onboarding — Device](screenshots/004_onboarding_device.png)

| Field | Value |
| --- | --- |
| **ID** | `onboarding_device` |
| **Route** | `/onboarding` |
| **Screenshot** | `screenshots/004_onboarding_device.png` |
| **Reached via** | Protocols step → Next |
| **Visible hints** | Connect a device, Skip device sync |

### INPUT (Home)

![INPUT (Home)](screenshots/005_shell_input.png)

| Field | Value |
| --- | --- |
| **ID** | `shell_input` |
| **Route** | `/shell` |
| **Screenshot** | `screenshots/005_shell_input.png` |
| **Reached via** | Onboarding skip device → shell |
| **Visible hints** | Input, Insights, Menu |

### INSIGHTS

![INSIGHTS](screenshots/006_shell_insights.png)

| Field | Value |
| --- | --- |
| **ID** | `shell_insights` |
| **Route** | `/shell` |
| **Screenshot** | `screenshots/006_shell_insights.png` |
| **Reached via** | Bottom nav → Insights |
| **Visible hints** | What Sanctum learned |

### INPUT

![INPUT](screenshots/007_shell_input.png)

| Field | Value |
| --- | --- |
| **ID** | `shell_input` |
| **Route** | `/shell` |
| **Screenshot** | `screenshots/007_shell_input.png` |
| **Reached via** | Bottom nav → Input |

### Focus Switcher Sheet

![Focus Switcher Sheet](screenshots/008_focus_switcher.png)

| Field | Value |
| --- | --- |
| **ID** | `focus_switcher` |
| **Route** | `—` |
| **Screenshot** | `screenshots/008_focus_switcher.png` |
| **Reached via** | Header focus title tap |
| **Visible hints** | Switch Focus, Add Focus |

### Protocols

![Protocols](screenshots/009_protocols_list.png)

| Field | Value |
| --- | --- |
| **ID** | `protocols_list` |
| **Route** | `/protocols` |
| **Screenshot** | `screenshots/009_protocols_list.png` |
| **Reached via** | INPUT → View all / Add protocol |

### Capture — Vitals / Check-in

![Capture — Vitals / Check-in](screenshots/010_capture_vitals.png)

| Field | Value |
| --- | --- |
| **ID** | `capture_vitals` |
| **Route** | `/capture/form` |
| **Screenshot** | `screenshots/010_capture_vitals.png` |
| **Reached via** | INPUT card → Daily Check-In |

### More / Menu

![More / Menu](screenshots/011_menu.png)

| Field | Value |
| --- | --- |
| **ID** | `menu` |
| **Route** | `/menu` |
| **Screenshot** | `screenshots/011_menu.png` |
| **Reached via** | Bottom nav → Menu |
| **Visible hints** | Devices, Settings, Sign out |

### Devices

![Devices](screenshots/012_menu__more_devices.png)

| Field | Value |
| --- | --- |
| **ID** | `menu__more_devices` |
| **Route** | `/more/devices` |
| **Screenshot** | `screenshots/012_menu__more_devices.png` |
| **Reached via** | Menu → Devices |

### Device Bridge / Wearable Sync

![Device Bridge / Wearable Sync](screenshots/013_device_bridge.png)

| Field | Value |
| --- | --- |
| **ID** | `device_bridge` |
| **Route** | `/more/device-bridge` |
| **Screenshot** | `screenshots/013_device_bridge.png` |
| **Reached via** | Devices → Device bridge |

### Goals

![Goals](screenshots/014_menu__more_goals.png)

| Field | Value |
| --- | --- |
| **ID** | `menu__more_goals` |
| **Route** | `/more/goals` |
| **Screenshot** | `screenshots/014_menu__more_goals.png` |
| **Reached via** | Menu → Goals |

### Reports

![Reports](screenshots/015_menu__more_reports.png)

| Field | Value |
| --- | --- |
| **ID** | `menu__more_reports` |
| **Route** | `/more/reports` |
| **Screenshot** | `screenshots/015_menu__more_reports.png` |
| **Reached via** | Menu → Reports |

### Data management

![Data management](screenshots/016_menu__more_data.png)

| Field | Value |
| --- | --- |
| **ID** | `menu__more_data` |
| **Route** | `/more/data` |
| **Screenshot** | `screenshots/016_menu__more_data.png` |
| **Reached via** | Menu → Data management |

### Settings

![Settings](screenshots/017_menu__more_settings.png)

| Field | Value |
| --- | --- |
| **ID** | `menu__more_settings` |
| **Route** | `/more/settings` |
| **Screenshot** | `screenshots/017_menu__more_settings.png` |
| **Reached via** | Menu → Settings |

### Practitioner mode

![Practitioner mode](screenshots/018_menu__more_practitioner.png)

| Field | Value |
| --- | --- |
| **ID** | `menu__more_practitioner` |
| **Route** | `/more/practitioner` |
| **Screenshot** | `screenshots/018_menu__more_practitioner.png` |
| **Reached via** | Menu → Practitioner mode |

### Library

![Library](screenshots/019_menu__more_library.png)

| Field | Value |
| --- | --- |
| **ID** | `menu__more_library` |
| **Route** | `/more/library` |
| **Screenshot** | `screenshots/019_menu__more_library.png` |
| **Reached via** | Menu → Library |

### Connect Sanctum (after sign out)

![Connect Sanctum (after sign out)](screenshots/020_auth_returning.png)

| Field | Value |
| --- | --- |
| **ID** | `auth_returning` |
| **Route** | `/auth` |
| **Screenshot** | `screenshots/020_auth_returning.png` |
| **Reached via** | Menu → Sign out |

### Onboarding (resumed)

![Onboarding (resumed)](screenshots/021_onboarding_resume.png)

| Field | Value |
| --- | --- |
| **ID** | `onboarding_resume` |
| **Route** | `/onboarding` |
| **Screenshot** | `screenshots/021_onboarding_resume.png` |
| **Reached via** | Continue without prior onboarded state |

### INPUT (returning user)

![INPUT (returning user)](screenshots/022_shell_input_returning.png)

| Field | Value |
| --- | --- |
| **ID** | `shell_input_returning` |
| **Route** | `/shell` |
| **Screenshot** | `screenshots/022_shell_input_returning.png` |
| **Reached via** | Auth → Continue |

### INSIGHTS

![INSIGHTS](screenshots/023_shell_insights_r2.png)

| Field | Value |
| --- | --- |
| **ID** | `shell_insights_r2` |
| **Route** | `/shell` |
| **Screenshot** | `screenshots/023_shell_insights_r2.png` |
| **Reached via** | Bottom nav → Insights |
| **Visible hints** | What Sanctum learned |

### INPUT

![INPUT](screenshots/024_shell_input_r2.png)

| Field | Value |
| --- | --- |
| **ID** | `shell_input_r2` |
| **Route** | `/shell` |
| **Screenshot** | `screenshots/024_shell_input_r2.png` |
| **Reached via** | Bottom nav → Input |

### Focus Switcher Sheet

![Focus Switcher Sheet](screenshots/025_focus_switcher_r2.png)

| Field | Value |
| --- | --- |
| **ID** | `focus_switcher_r2` |
| **Route** | `—` |
| **Screenshot** | `screenshots/025_focus_switcher_r2.png` |
| **Reached via** | Header focus title tap |
| **Visible hints** | Switch Focus, Add Focus |

### More / Menu

![More / Menu](screenshots/026_menu_r2.png)

| Field | Value |
| --- | --- |
| **ID** | `menu_r2` |
| **Route** | `/menu` |
| **Screenshot** | `screenshots/026_menu_r2.png` |
| **Reached via** | Bottom nav → Menu |
| **Visible hints** | Devices, Settings, Sign out |

## Failures (continued run)

- **focus_switcher:close**: No back navigation available (from `focus_switcher`)
- **nav:menu-for-signout**: Text not found: "Menu" (from `menu__more_library`)
- **onboarding:skip-header**: Text not found: "Skip" (from `onboarding_resume`)
- **onboarding:resume-focus**: Text not found: "Sleep Optimization" (from `onboarding_resume`)
- **onboarding:resume-skip**: Text not found: "Skip device sync" (from `onboarding_resume`)
- **tab:insights_r2**: Text not found: "Insights" (from `shell_input_returning`)
- **tab:input_r2**: Text not found: "Input" (from `shell_insights_r2`)
- **focus_switcher:close**: No back navigation available (from `focus_switcher_r2`)
- **tab:menu_r2**: Text not found: "Menu" (from `focus_switcher_r2`)

## Navigation edges

| From | Action | To | OK |
| --- | --- | --- | --- |
| `splash` | auto-route | `auth` | ✓ |
| `auth` | Tap "New here — set up my journal" | `onboarding_welcome` | ✓ |
| `auth` | New here — set up my journal | `onboarding_welcome` | ✓ |
| `onboarding_welcome` | Next | `onboarding_focus` | ✓ |
| `onboarding_focus` | Next | `onboarding_protocols` | ✓ |
| `onboarding_protocols` | Next | `onboarding_device` | ✓ |
| `onboarding_device` | Skip device sync | `shell_input` | ✓ |
| `shell_input` | Insights tab | `shell_insights` | ✓ |
| `shell_insights` | Input tab | `shell_input` | ✓ |
| `shell_input` | Tap focus title | `focus_switcher` | ✓ |
| `shell_input` | Menu tab | `menu` | ✓ |
| `menu` | Tap Devices | `menu__more_devices` | ✓ |
| `menu` | Tap Goals | `menu__more_goals` | ✓ |
| `menu` | Tap Reports | `menu__more_reports` | ✓ |
| `menu` | Tap Data management | `menu__more_data` | ✓ |
| `menu` | Tap Settings | `menu__more_settings` | ✓ |
| `menu` | Tap Practitioner mode | `menu__more_practitioner` | ✓ |
| `menu` | Tap Library | `menu__more_library` | ✓ |
| `menu` | Sign out | `auth_returning` | ✓ |
| `auth_returning` | Continue | `shell_input_returning` | ✓ |
| `shell_input_r2` | Insights tab | `shell_insights_r2` | ✓ |
| `shell_insights_r2` | Input tab | `shell_input_r2` | ✓ |
| `shell_input_r2` | Tap focus title | `focus_switcher_r2` | ✓ |
| `shell_input_r2` | Menu tab | `menu_r2` | ✓ |

