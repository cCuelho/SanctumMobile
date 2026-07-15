#!/usr/bin/env bash
# Run guided navigation screenshot mapper on iOS Simulator.
# Outputs: test_outputs/navigation_map/{navigation_map.md, navigation_map_ux.html, navigation_flow.mmd, session.json, screenshots/}
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUTPUT_DIR="$ROOT/test_outputs/navigation_map"
DEVICE="${SANCTUM_SIMULATOR_DEVICE:-}"

mkdir -p "$OUTPUT_DIR/screenshots"

if [[ -z "$DEVICE" ]]; then
  DEVICE="$(flutter devices --machine 2>/dev/null | python3 -c "
import json, sys
for d in json.load(sys.stdin):
    platform = d.get('targetPlatform') or d.get('platform')
    if platform == 'ios' and d.get('emulator'):
        print(d['id']); break
" 2>/dev/null || true)"
fi

if [[ -z "$DEVICE" ]]; then
  echo "No iOS simulator found. Set SANCTUM_SIMULATOR_DEVICE or boot a simulator."
  exit 1
fi

echo "Running navigation map on device: $DEVICE"

LOG_FILE="$OUTPUT_DIR/test_run.log"
export NAV_MAP_SCREENSHOT_DIR="$OUTPUT_DIR/screenshots"

# flutter drive + onScreenshot driver writes PNGs to NAV_MAP_SCREENSHOT_DIR
flutter drive \
  --driver=test_driver/navigation_map_driver.dart \
  --target=integration_test/navigation_map_test.dart \
  --dart-define=INTEGRATION_TEST=true \
  --dart-define=SANCTUM_API_BASE="${SANCTUM_API_BASE:-http://127.0.0.1:5000}" \
  -d "$DEVICE" \
  2>&1 | tee "$LOG_FILE"

# Extract session JSON + markdown/mermaid from integration_response_data.json
python3 - <<'PY' "$LOG_FILE" "$OUTPUT_DIR" "$ROOT"
import html
import json
import pathlib
import sys

log = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
root = pathlib.Path(sys.argv[3])

data = None
resp_candidates = sorted(root.glob("build/**/integration_response_data.json"))
for candidate in reversed(resp_candidates):
    try:
        resp = json.loads(candidate.read_text(encoding="utf-8"))
        if resp.get("navigation_map"):
            data = resp["navigation_map"]
            break
    except (json.JSONDecodeError, OSError):
        continue

if data is None:
    print("Warning: navigation_map not found in integration_response_data.json", file=sys.stderr)
    sys.exit(0)

session = data["session"]
(out / "session.json").write_text(json.dumps(session, indent=2), encoding="utf-8")
(out / "navigation_map.md").write_text(data["markdown"], encoding="utf-8")
(out / "navigation_flow.mmd").write_text(data["mermaid"], encoding="utf-8")
print(f"Wrote {out / 'navigation_map.md'}")
print(f"Wrote {out / 'navigation_flow.mmd'}")

# UX-facing HTML deck (open in browser or zip screenshots/ + this file for designers)
pages = session.get("pages", [])
failures = session.get("failures", [])
edges = session.get("edges", [])
screens_dir = out / "screenshots"

cards = []
for i, page in enumerate(pages, start=1):
    shot = page.get("screenshotFile", "")
    shot_path = screens_dir / shot
    img = (
        f'<img src="screenshots/{html.escape(shot)}" alt="{html.escape(page.get("title", ""))}" loading="lazy" />'
        if shot_path.is_file()
        else '<p class="missing">Screenshot missing — re-run with flutter drive.</p>'
    )
    hints = page.get("visibleHints") or []
    hint_html = (
        f"<p><strong>Visible:</strong> {html.escape(', '.join(hints))}</p>" if hints else ""
    )
    cards.append(
        f"""
<section class="card" id="{html.escape(page.get('id', f'page-{i}'))}">
  <header>
    <span class="num">{i:02d}</span>
    <h2>{html.escape(page.get('title', 'Untitled'))}</h2>
  </header>
  <div class="shot">{img}</div>
  <dl>
    <dt>Reached via</dt><dd>{html.escape(page.get('reachedVia', '—'))}</dd>
    <dt>Route</dt><dd><code>{html.escape(page.get('route') or '—')}</code></dd>
    <dt>Screen ID</dt><dd><code>{html.escape(page.get('id', '—'))}</code></dd>
  </dl>
  {hint_html}
</section>"""
    )

fail_list = "".join(
    f"<li><strong>{html.escape(f.get('step', ''))}</strong>: {html.escape(f.get('message', ''))}</li>"
    for f in failures
)
edge_rows = "".join(
    f"<tr><td><code>{html.escape(e.get('fromId', ''))}</code></td>"
    f"<td>{html.escape(e.get('action', ''))}</td>"
    f"<td><code>{html.escape(e.get('toId', ''))}</code></td>"
    f"<td>{'✓' if e.get('success') else '✗'}</td></tr>"
    for e in edges
)

ux_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Sanctum Mobile — Navigation Map</title>
  <style>
    :root {{ font-family: system-ui, -apple-system, Segoe UI, sans-serif; color: #0f172a; background: #f8f7f4; }}
    body {{ margin: 0; padding: 24px; max-width: 1100px; margin-inline: auto; }}
    h1 {{ margin-bottom: 0.25rem; }}
    .meta {{ color: #475569; margin-bottom: 2rem; }}
    .card {{ background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; margin-bottom: 24px; box-shadow: 0 1px 2px rgba(0,0,0,.04); }}
    .card header {{ display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }}
    .num {{ background: #2e2a6e; color: #fff; font-weight: 700; border-radius: 8px; padding: 4px 10px; font-size: 0.85rem; }}
    .shot img {{ width: 100%; max-width: 390px; border-radius: 16px; border: 1px solid #cbd5e1; display: block; }}
    .missing {{ color: #a8435f; font-style: italic; }}
    dl {{ display: grid; grid-template-columns: 120px 1fr; gap: 6px 12px; margin: 12px 0 0; }}
    dt {{ font-weight: 600; color: #64748b; }}
    dd {{ margin: 0; }}
    table {{ width: 100%; border-collapse: collapse; font-size: 0.9rem; }}
    th, td {{ border: 1px solid #e2e8f0; padding: 8px; text-align: left; }}
    th {{ background: #f1f5f9; }}
    .failures {{ background: #fff5f5; border: 1px solid #fecaca; border-radius: 8px; padding: 12px 20px; }}
  </style>
</head>
<body>
  <h1>Sanctum Mobile — Navigation Map</h1>
  <p class="meta">Pages: {len(pages)} · Edges: {len(edges)} · Failures: {len(failures)} · Screenshots on disk: {len(list(screens_dir.glob('*.png')))}</p>
  <p class="meta">Share this file plus the <code>screenshots/</code> folder with your UX specialist. Open locally in Chrome or Safari.</p>

  {"".join(cards)}

  <section class="card">
    <h2>Navigation edges</h2>
    <table>
      <thead><tr><th>From</th><th>Action</th><th>To</th><th>OK</th></tr></thead>
      <tbody>{edge_rows}</tbody>
    </table>
  </section>

  {"<section class='card failures'><h2>Automation gaps</h2><ul>" + fail_list + "</ul><p>These did not stop the run; flows after them may be partial.</p></section>" if failures else ""}
</body>
</html>
"""

(out / "navigation_map_ux.html").write_text(ux_html, encoding="utf-8")
print(f"Wrote {out / 'navigation_map_ux.html'}")
PY

SHOT_COUNT="$(find "$OUTPUT_DIR/screenshots" -maxdepth 1 -name '*.png' 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo "Done. Artifacts in $OUTPUT_DIR"
echo "  UX deck:      $OUTPUT_DIR/navigation_map_ux.html"
echo "  Markdown:     $OUTPUT_DIR/navigation_map.md"
echo "  Screenshots:  $SHOT_COUNT files in $OUTPUT_DIR/screenshots/"
if [[ "$SHOT_COUNT" == "0" ]]; then
  echo "  Warning: no screenshots captured — ensure you used this script (flutter drive), not flutter test directly."
fi
