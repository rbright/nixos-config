#!/usr/bin/env python3
"""
Waybar Codex/Claude usage module.

Outputs Waybar-compatible JSON:
- text: icon + weekly remaining percent
- tooltip: session/weekly remaining + reset times + today/30d token/cost

Auth strategy (no repo secrets):
- Codex: ~/.codex/auth.json (or $WAYBAR_AI_CODEX_AUTH_FILE)
- Claude: ~/.claude/.credentials.json (or $WAYBAR_AI_CLAUDE_CREDENTIALS_FILE)
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import math
import os
from pathlib import Path
import re
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request


# ---------------------------------------------------------------------------
# Config / constants
# ---------------------------------------------------------------------------

CODEX_REFRESH_ENDPOINT = "https://auth.openai.com/oauth/token"
CODEX_REFRESH_CLIENT_ID = "app_EMoamEEZ73f0CkXaXp7hrann"
CODEX_USAGE_URL = "https://chatgpt.com/backend-api/wham/usage"

CLAUDE_REFRESH_ENDPOINT = "https://platform.claude.com/v1/oauth/token"
CLAUDE_USAGE_URL = "https://api.anthropic.com/api/oauth/usage"
CLAUDE_USAGE_BETA = "oauth-2025-04-20"
CLAUDE_CLIENT_ID_DEFAULT = "9d1c250a-e61b-44d9-88ed-5944d1962f5e"

# Mirrors CodexBar vendored CostUsagePricing (Codex + Claude only)
CODEX_PRICING = {
    "gpt-5": (1.25e-6, 1e-5, 1.25e-7),
    "gpt-5-codex": (1.25e-6, 1e-5, 1.25e-7),
    "gpt-5.1": (1.25e-6, 1e-5, 1.25e-7),
    "gpt-5.2": (1.75e-6, 1.4e-5, 1.75e-7),
    "gpt-5.2-codex": (1.75e-6, 1.4e-5, 1.75e-7),
}

CLAUDE_PRICING = {
    "claude-haiku-4-5-20251001": (1e-6, 5e-6, 1.25e-6, 1e-7, None, None, None, None, None),
    "claude-haiku-4-5": (1e-6, 5e-6, 1.25e-6, 1e-7, None, None, None, None, None),
    "claude-opus-4-5-20251101": (5e-6, 2.5e-5, 6.25e-6, 5e-7, None, None, None, None, None),
    "claude-opus-4-5": (5e-6, 2.5e-5, 6.25e-6, 5e-7, None, None, None, None, None),
    "claude-opus-4-6-20260205": (5e-6, 2.5e-5, 6.25e-6, 5e-7, None, None, None, None, None),
    "claude-opus-4-6": (5e-6, 2.5e-5, 6.25e-6, 5e-7, None, None, None, None, None),
    "claude-sonnet-4-5": (3e-6, 1.5e-5, 3.75e-6, 3e-7, 200_000, 6e-6, 2.25e-5, 7.5e-6, 6e-7),
    "claude-sonnet-4-5-20250929": (3e-6, 1.5e-5, 3.75e-6, 3e-7, 200_000, 6e-6, 2.25e-5, 7.5e-6, 6e-7),
    "claude-opus-4-20250514": (1.5e-5, 7.5e-5, 1.875e-5, 1.5e-6, None, None, None, None, None),
    "claude-opus-4-1": (1.5e-5, 7.5e-5, 1.875e-5, 1.5e-6, None, None, None, None, None),
    "claude-sonnet-4-20250514": (3e-6, 1.5e-5, 3.75e-6, 3e-7, 200_000, 6e-6, 2.25e-5, 7.5e-6, 6e-7),
}


class UsageError(Exception):
    pass


# ---------------------------------------------------------------------------
# Generic helpers
# ---------------------------------------------------------------------------


def read_json(path: Path) -> dict:
    try:
        with path.open("r", encoding="utf-8") as fh:
            data = json.load(fh)
        if isinstance(data, dict):
            return data
    except FileNotFoundError as exc:
        raise UsageError(f"Missing file: {path}") from exc
    except json.JSONDecodeError as exc:
        raise UsageError(f"Invalid JSON: {path}") from exc
    raise UsageError(f"Unexpected JSON structure: {path}")



def write_json_atomic(path: Path, payload: dict, mode: int = 0o600) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", delete=False, dir=path.parent, encoding="utf-8") as fh:
        tmp_path = Path(fh.name)
        json.dump(payload, fh, ensure_ascii=False, indent=2)
        fh.write("\n")
    os.chmod(tmp_path, mode)
    tmp_path.replace(path)



def load_env_file(path: Path) -> None:
    if not path.exists():
        return
    try:
        content = path.read_text(encoding="utf-8")
    except OSError:
        return

    for raw in content.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[len("export ") :].strip()
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()
        if not key:
            continue
        if value.startswith(("\"", "'")) and value.endswith(("\"", "'")) and len(value) >= 2:
            value = value[1:-1]
        os.environ.setdefault(key, value)



def now_utc() -> dt.datetime:
    return dt.datetime.now(dt.timezone.utc)



def parse_iso8601(value: str | None) -> dt.datetime | None:
    if not value:
        return None
    text = value.strip()
    if not text:
        return None
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    try:
        parsed = dt.datetime.fromisoformat(text)
    except ValueError:
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=dt.timezone.utc)
    return parsed.astimezone(dt.timezone.utc)



def parse_epoch_seconds(value: int | float | str | None) -> dt.datetime | None:
    if value is None:
        return None
    try:
        return dt.datetime.fromtimestamp(float(value), tz=dt.timezone.utc)
    except (TypeError, ValueError, OSError):
        return None



def parse_epoch_millis(value: int | float | str | None) -> dt.datetime | None:
    if value is None:
        return None
    try:
        return dt.datetime.fromtimestamp(float(value) / 1000.0, tz=dt.timezone.utc)
    except (TypeError, ValueError, OSError):
        return None



def as_datetime(value) -> dt.datetime | None:
    if isinstance(value, dt.datetime):
        if value.tzinfo is None:
            return value.replace(tzinfo=dt.timezone.utc)
        return value.astimezone(dt.timezone.utc)
    if isinstance(value, str):
        return parse_iso8601(value)
    if isinstance(value, (int, float)):
        if value > 10_000_000_000:
            return parse_epoch_millis(value)
        return parse_epoch_seconds(value)
    return None



def to_iso_z(value) -> str | None:
    parsed = as_datetime(value)
    if not parsed:
        return None
    return parsed.replace(microsecond=0).isoformat().replace("+00:00", "Z")



def pct_remaining(used_percent: float | int | None) -> float | None:
    if used_percent is None:
        return None
    try:
        used = float(used_percent)
    except (TypeError, ValueError):
        return None
    return max(0.0, min(100.0, 100.0 - used))



def day_key_from_timestamp(value: str | None) -> str | None:
    if not value:
        return None
    text = value.strip()
    if len(text) >= 10 and text[4] == "-" and text[7] == "-":
        return text[:10]
    parsed = parse_iso8601(text)
    if not parsed:
        return None
    return parsed.astimezone().date().isoformat()



def to_int(value) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return 0



def fmt_percent(value: float | None) -> str:
    if value is None:
        return "—"
    return f"{int(round(max(0.0, min(100.0, value))))}%"



def fmt_tokens(value: int | None) -> str:
    if value is None:
        return "—"
    n = abs(value)
    sign = "-" if value < 0 else ""
    units = ((1_000_000_000, "B"), (1_000_000, "M"), (1_000, "K"))
    for threshold, suffix in units:
        if n >= threshold:
            scaled = n / threshold
            if scaled >= 10:
                return f"{sign}{scaled:.0f}{suffix}"
            pretty = f"{scaled:.1f}".rstrip("0").rstrip(".")
            return f"{sign}{pretty}{suffix}"
    return f"{value:,}"



def fmt_usd(value: float | None) -> str:
    if value is None:
        return "—"
    return f"${value:,.2f}"



def fmt_money(value: float | None, currency: str | None = None) -> str:
    code = (currency or "USD").strip().upper()
    if code == "USD":
        return fmt_usd(value)
    if value is None:
        return "—"
    return f"{value:,.2f} {code}"



def format_relative(delta_seconds: float) -> str:
    sec = max(0, int(delta_seconds))
    if sec < 60:
        return "just now"
    minutes = sec // 60
    if minutes < 60:
        return f"{minutes}m ago"
    hours = minutes // 60
    if hours < 24:
        return f"{hours}h ago"
    days = hours // 24
    return f"{days}d ago"



def reset_countdown_text(reset_at: dt.datetime | None) -> str:
    if not reset_at:
        return "—"
    now = now_utc()
    diff = int((reset_at - now).total_seconds())
    if diff <= 0:
        return "now"
    minutes = max(1, math.ceil(diff / 60))
    days, rem_m = divmod(minutes, 24 * 60)
    hours, mins = divmod(rem_m, 60)
    if days > 0:
        return f"in {days}d {hours}h" if hours else f"in {days}d"
    if hours > 0:
        return f"in {hours}h {mins}m" if mins else f"in {hours}h"
    return f"in {mins}m"



def reset_absolute_text(reset_at: dt.datetime | None) -> str:
    if not reset_at:
        return "—"
    local = reset_at.astimezone()
    return local.strftime("%b %-d, %-I:%M %p")



def http_json(
    url: str,
    headers: dict[str, str],
    timeout: float,
    method: str = "GET",
    body: bytes | None = None,
) -> dict:
    request = urllib.request.Request(url=url, method=method, data=body)
    for key, value in headers.items():
        request.add_header(key, value)

    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            data = response.read()
            try:
                parsed = json.loads(data)
            except json.JSONDecodeError as exc:
                raise UsageError(f"Invalid API JSON from {url}") from exc
            if not isinstance(parsed, dict):
                raise UsageError(f"Unexpected API payload from {url}")
            return parsed
    except urllib.error.HTTPError as exc:
        payload = ""
        try:
            payload = exc.read().decode("utf-8", errors="replace").strip()
        except Exception:
            payload = ""
        if payload:
            raise UsageError(f"HTTP {exc.code}: {payload[:220]}") from exc
        raise UsageError(f"HTTP {exc.code} from {url}") from exc
    except urllib.error.URLError as exc:
        raise UsageError(f"Network error: {exc.reason}") from exc



def is_http_status(message: str, status: int) -> bool:
    return f"http {status}" in message.lower()



def is_http_5xx_error(message: str) -> bool:
    lower = message.lower()
    return any(f"http {code}" in lower for code in (500, 502, 503, 504))


# ---------------------------------------------------------------------------
# Pricing helpers
# ---------------------------------------------------------------------------


def normalize_codex_model(raw: str | None) -> str:
    value = (raw or "").strip()
    if value.startswith("openai/"):
        value = value[len("openai/") :]
    if "-codex" in value:
        base = value.split("-codex", 1)[0]
        if base in CODEX_PRICING:
            return base
    return value



def codex_cost_usd(model: str | None, input_tokens: int, cached_input_tokens: int, output_tokens: int) -> float | None:
    key = normalize_codex_model(model)
    pricing = CODEX_PRICING.get(key)
    if not pricing:
        return None
    input_rate, output_rate, cache_rate = pricing
    cached = min(max(0, cached_input_tokens), max(0, input_tokens))
    non_cached = max(0, input_tokens - cached)
    return non_cached * input_rate + cached * cache_rate + max(0, output_tokens) * output_rate



def normalize_claude_model(raw: str | None) -> str:
    value = (raw or "").strip()
    if value.startswith("anthropic."):
        value = value[len("anthropic.") :]

    if "." in value and "claude-" in value:
        tail = value.rsplit(".", 1)[-1]
        if tail.startswith("claude-"):
            value = tail

    value = re.sub(r"-v\d+:\d+$", "", value)
    dated = re.sub(r"-\d{8}$", "", value)
    if dated in CLAUDE_PRICING:
        return dated
    return value



def _tiered_cost(tokens: int, base: float, threshold: int | None, above: float | None) -> float:
    t = max(0, tokens)
    if threshold is None or above is None:
        return t * base
    below = min(t, threshold)
    over = max(0, t - threshold)
    return below * base + over * above



def claude_cost_usd(
    model: str | None,
    input_tokens: int,
    cache_read_input_tokens: int,
    cache_creation_input_tokens: int,
    output_tokens: int,
) -> float | None:
    key = normalize_claude_model(model)
    pricing = CLAUDE_PRICING.get(key)
    if not pricing:
        return None

    (
        in_rate,
        out_rate,
        cache_create_rate,
        cache_read_rate,
        threshold,
        in_above,
        out_above,
        cache_create_above,
        cache_read_above,
    ) = pricing

    return (
        _tiered_cost(input_tokens, in_rate, threshold, in_above)
        + _tiered_cost(cache_read_input_tokens, cache_read_rate, threshold, cache_read_above)
        + _tiered_cost(cache_creation_input_tokens, cache_create_rate, threshold, cache_create_above)
        + _tiered_cost(output_tokens, out_rate, threshold, out_above)
    )


# ---------------------------------------------------------------------------
# Token/cost usage scan (today + last 30 days)
# ---------------------------------------------------------------------------


def empty_day_bucket() -> dict:
    return {
        "tokens": 0,
        "cost": 0.0,
        "cost_seen": False,
    }



def summarize_days(days: dict[str, dict]) -> dict:
    if not days:
        return {
            "today_tokens": None,
            "today_cost_usd": None,
            "last30_tokens": None,
            "last30_cost_usd": None,
        }

    latest_day = max(days.keys())
    latest = days[latest_day]

    total_tokens = 0
    total_cost = 0.0
    cost_seen = False
    for bucket in days.values():
        total_tokens += bucket["tokens"]
        if bucket["cost_seen"]:
            total_cost += bucket["cost"]
            cost_seen = True

    return {
        "today_tokens": latest["tokens"] if latest["tokens"] > 0 else None,
        "today_cost_usd": latest["cost"] if latest["cost_seen"] else None,
        "last30_tokens": total_tokens if total_tokens > 0 else None,
        "last30_cost_usd": total_cost if cost_seen else None,
    }



def iter_codex_session_files(codex_home: Path, since_day: dt.date, until_day: dt.date) -> list[Path]:
    files: list[Path] = []
    roots = [codex_home / "sessions", codex_home / "archived_sessions"]

    day = since_day
    while day <= until_day:
        for root in roots:
            day_dir = root / f"{day.year:04d}" / f"{day.month:02d}" / f"{day.day:02d}"
            if day_dir.exists():
                files.extend(sorted(day_dir.glob("*.jsonl")))
        day += dt.timedelta(days=1)

    # Compatibility: scan flat JSONL files directly under session roots.
    for root in roots:
        if root.exists():
            files.extend(sorted(root.glob("*.jsonl")))

    # de-dupe by path order
    seen: set[str] = set()
    out: list[Path] = []
    for file_path in files:
        key = str(file_path)
        if key in seen:
            continue
        seen.add(key)
        out.append(file_path)
    return out



def scan_codex_local_usage(codex_home: Path, since_day: dt.date, until_day: dt.date) -> dict:
    since_key = since_day.isoformat()
    until_key = until_day.isoformat()
    files = iter_codex_session_files(codex_home, since_day, until_day)

    days: dict[str, dict] = {}
    for file_path in files:
        current_model: str | None = None
        previous_totals: tuple[int, int, int] | None = None

        try:
            with file_path.open("r", encoding="utf-8") as fh:
                for raw in fh:
                    line = raw.strip()
                    if not line:
                        continue
                    try:
                        obj = json.loads(line)
                    except json.JSONDecodeError:
                        continue
                    if not isinstance(obj, dict):
                        continue

                    typ = obj.get("type")
                    if typ == "turn_context":
                        payload = obj.get("payload")
                        if isinstance(payload, dict):
                            model = payload.get("model")
                            if isinstance(model, str) and model.strip():
                                current_model = model.strip()
                        continue

                    if typ != "event_msg":
                        continue

                    payload = obj.get("payload")
                    if not isinstance(payload, dict) or payload.get("type") != "token_count":
                        continue

                    info = payload.get("info")
                    if not isinstance(info, dict):
                        continue

                    timestamp = obj.get("timestamp")
                    day_key = day_key_from_timestamp(timestamp)
                    if not day_key or day_key < since_key or day_key > until_key:
                        continue

                    model = (
                        info.get("model")
                        or info.get("model_name")
                        or payload.get("model")
                        or obj.get("model")
                        or current_model
                        or "gpt-5"
                    )

                    delta_input = 0
                    delta_cached = 0
                    delta_output = 0

                    totals = info.get("total_token_usage")
                    if isinstance(totals, dict):
                        t_input = max(0, to_int(totals.get("input_tokens")))
                        t_cached = max(
                            0,
                            to_int(totals.get("cached_input_tokens") or totals.get("cache_read_input_tokens")),
                        )
                        t_output = max(0, to_int(totals.get("output_tokens")))

                        if previous_totals is None:
                            last = info.get("last_token_usage")
                            if isinstance(last, dict):
                                delta_input = max(0, to_int(last.get("input_tokens")))
                                delta_cached = max(
                                    0,
                                    to_int(last.get("cached_input_tokens") or last.get("cache_read_input_tokens")),
                                )
                                delta_output = max(0, to_int(last.get("output_tokens")))
                        else:
                            p_input, p_cached, p_output = previous_totals
                            delta_input = max(0, t_input - p_input)
                            delta_cached = max(0, t_cached - p_cached)
                            delta_output = max(0, t_output - p_output)

                        previous_totals = (t_input, t_cached, t_output)
                    else:
                        last = info.get("last_token_usage")
                        if isinstance(last, dict):
                            delta_input = max(0, to_int(last.get("input_tokens")))
                            delta_cached = max(
                                0,
                                to_int(last.get("cached_input_tokens") or last.get("cache_read_input_tokens")),
                            )
                            delta_output = max(0, to_int(last.get("output_tokens")))

                    if delta_input == 0 and delta_cached == 0 and delta_output == 0:
                        continue

                    cached_clamped = min(delta_cached, delta_input)
                    total_tokens = delta_input + delta_output
                    cost = codex_cost_usd(model, delta_input, cached_clamped, delta_output)

                    bucket = days.setdefault(day_key, empty_day_bucket())
                    bucket["tokens"] += total_tokens
                    if cost is not None:
                        bucket["cost"] += cost
                        bucket["cost_seen"] = True
        except OSError:
            continue

    return summarize_days(days)



def claude_project_roots() -> list[Path]:
    env_value = os.environ.get("CLAUDE_CONFIG_DIR", "").strip()
    roots: list[Path] = []

    if env_value:
        for chunk in env_value.split(","):
            raw = chunk.strip()
            if not raw:
                continue
            p = Path(raw)
            if p.name == "projects":
                roots.append(p)
            else:
                roots.append(p / "projects")
    else:
        roots.append(Path.home() / ".config" / "claude" / "projects")
        roots.append(Path.home() / ".claude" / "projects")

    deduped: list[Path] = []
    seen: set[str] = set()
    for root in roots:
        key = str(root)
        if key in seen:
            continue
        seen.add(key)
        deduped.append(root)
    return deduped



def scan_claude_local_usage(since_day: dt.date, until_day: dt.date) -> dict:
    since_key = since_day.isoformat()
    until_key = until_day.isoformat()
    days: dict[str, dict] = {}
    roots = claude_project_roots()

    # Fast coarse filter: no need to parse files untouched in the last 31 days.
    min_mtime = dt.datetime.combine(since_day - dt.timedelta(days=1), dt.time.min, tzinfo=dt.timezone.utc).timestamp()

    for root in roots:
        if not root.exists():
            continue

        try:
            jsonl_files = root.rglob("*.jsonl")
        except OSError:
            continue

        for file_path in jsonl_files:
            try:
                if file_path.stat().st_mtime < min_mtime:
                    continue
            except OSError:
                continue

            seen_pairs: set[tuple[str, str]] = set()
            try:
                with file_path.open("r", encoding="utf-8") as fh:
                    for raw in fh:
                        line = raw.strip()
                        if not line:
                            continue
                        try:
                            obj = json.loads(line)
                        except json.JSONDecodeError:
                            continue
                        if not isinstance(obj, dict) or obj.get("type") != "assistant":
                            continue

                        timestamp = obj.get("timestamp")
                        day_key = day_key_from_timestamp(timestamp)
                        if not day_key or day_key < since_key or day_key > until_key:
                            continue

                        message = obj.get("message")
                        if not isinstance(message, dict):
                            continue

                        usage = message.get("usage")
                        if not isinstance(usage, dict):
                            continue

                        message_id = str(message.get("id") or "")
                        request_id = str(obj.get("requestId") or "")
                        if message_id and request_id:
                            pair = (message_id, request_id)
                            if pair in seen_pairs:
                                continue
                            seen_pairs.add(pair)

                        model = message.get("model")
                        input_tokens = max(0, to_int(usage.get("input_tokens")))
                        cache_read = max(0, to_int(usage.get("cache_read_input_tokens")))
                        cache_create = max(0, to_int(usage.get("cache_creation_input_tokens")))
                        output_tokens = max(0, to_int(usage.get("output_tokens")))

                        if input_tokens == 0 and cache_read == 0 and cache_create == 0 and output_tokens == 0:
                            continue

                        total_tokens = input_tokens + cache_read + cache_create + output_tokens
                        cost = claude_cost_usd(
                            model,
                            input_tokens=input_tokens,
                            cache_read_input_tokens=cache_read,
                            cache_creation_input_tokens=cache_create,
                            output_tokens=output_tokens,
                        )

                        bucket = days.setdefault(day_key, empty_day_bucket())
                        bucket["tokens"] += total_tokens
                        if cost is not None:
                            bucket["cost"] += cost
                            bucket["cost_seen"] = True
            except OSError:
                continue

    return summarize_days(days)


# ---------------------------------------------------------------------------
# Provider fetchers
# ---------------------------------------------------------------------------


def codex_auth_file() -> Path:
    explicit = os.environ.get("WAYBAR_AI_CODEX_AUTH_FILE", "").strip()
    if explicit:
        return Path(explicit).expanduser()
    codex_home = os.environ.get("CODEX_HOME", "").strip() or str(Path.home() / ".codex")
    return Path(codex_home).expanduser() / "auth.json"



def codex_home_dir() -> Path:
    raw = os.environ.get("CODEX_HOME", "").strip() or str(Path.home() / ".codex")
    return Path(raw).expanduser()



def codex_refresh_if_needed(auth_data: dict, timeout: float) -> dict:
    tokens = auth_data.get("tokens") if isinstance(auth_data.get("tokens"), dict) else {}
    refresh_token = str(tokens.get("refresh_token") or "").strip()
    if not refresh_token:
        return auth_data

    last_refresh = parse_iso8601(str(auth_data.get("last_refresh") or ""))
    if last_refresh:
        age_seconds = (now_utc() - last_refresh).total_seconds()
        if age_seconds <= 8 * 24 * 60 * 60:
            return auth_data

    refreshed = http_json(
        CODEX_REFRESH_ENDPOINT,
        headers={"Content-Type": "application/json", "Accept": "application/json", "User-Agent": "waybar-ai-usage"},
        timeout=timeout,
        method="POST",
        body=json.dumps(
            {
                "client_id": CODEX_REFRESH_CLIENT_ID,
                "grant_type": "refresh_token",
                "refresh_token": refresh_token,
                "scope": "openid profile email",
            }
        ).encode("utf-8"),
    )

    access_token = str(refreshed.get("access_token") or "").strip()
    if not access_token:
        return auth_data

    if not isinstance(tokens, dict):
        tokens = {}
    tokens["access_token"] = access_token
    if isinstance(refreshed.get("refresh_token"), str) and refreshed["refresh_token"].strip():
        tokens["refresh_token"] = refreshed["refresh_token"].strip()
    if isinstance(refreshed.get("id_token"), str) and refreshed["id_token"].strip():
        tokens["id_token"] = refreshed["id_token"].strip()

    auth_data["tokens"] = tokens
    auth_data["last_refresh"] = now_utc().replace(microsecond=0).isoformat().replace("+00:00", "Z")
    return auth_data



def codex_refresh_on_unauthorized(auth_data: dict, timeout: float) -> dict:
    tokens = auth_data.get("tokens") if isinstance(auth_data.get("tokens"), dict) else {}
    refresh_token = str(tokens.get("refresh_token") or "").strip()
    if not refresh_token:
        raise UsageError("Codex auth expired. Run `codex login`.")

    refreshed = http_json(
        CODEX_REFRESH_ENDPOINT,
        headers={"Content-Type": "application/json", "Accept": "application/json", "User-Agent": "waybar-ai-usage"},
        timeout=timeout,
        method="POST",
        body=json.dumps(
            {
                "client_id": CODEX_REFRESH_CLIENT_ID,
                "grant_type": "refresh_token",
                "refresh_token": refresh_token,
                "scope": "openid profile email",
            }
        ).encode("utf-8"),
    )

    access_token = str(refreshed.get("access_token") or "").strip()
    if not access_token:
        raise UsageError("Codex token refresh failed. Run `codex login`.")

    tokens["access_token"] = access_token
    if isinstance(refreshed.get("refresh_token"), str) and refreshed["refresh_token"].strip():
        tokens["refresh_token"] = refreshed["refresh_token"].strip()
    if isinstance(refreshed.get("id_token"), str) and refreshed["id_token"].strip():
        tokens["id_token"] = refreshed["id_token"].strip()

    auth_data["tokens"] = tokens
    auth_data["last_refresh"] = now_utc().replace(microsecond=0).isoformat().replace("+00:00", "Z")
    return auth_data



def codex_fetch(timeout: float) -> dict:
    path = codex_auth_file()
    auth_data = read_json(path)

    # Prefer env override if explicitly provided.
    access_override = os.environ.get("WAYBAR_AI_CODEX_ACCESS_TOKEN", "").strip()
    account_override = os.environ.get("WAYBAR_AI_CODEX_ACCOUNT_ID", "").strip()

    auth_data = codex_refresh_if_needed(auth_data, timeout=timeout)

    tokens = auth_data.get("tokens") if isinstance(auth_data.get("tokens"), dict) else {}
    access_token = access_override or str(tokens.get("access_token") or auth_data.get("OPENAI_API_KEY") or "").strip()
    account_id = account_override or str(tokens.get("account_id") or "").strip()

    if not access_token:
        raise UsageError("Codex token missing. Run `codex login`.")

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json",
        "User-Agent": "waybar-ai-usage",
    }
    if account_id:
        headers["ChatGPT-Account-Id"] = account_id

    try:
        usage = http_json(CODEX_USAGE_URL, headers=headers, timeout=timeout)
    except UsageError as exc:
        message = str(exc)
        if "HTTP 401" in message or "HTTP 403" in message:
            auth_data = codex_refresh_on_unauthorized(auth_data, timeout=timeout)
            tokens = auth_data.get("tokens") if isinstance(auth_data.get("tokens"), dict) else {}
            access_token = str(tokens.get("access_token") or "").strip()
            if not access_token:
                raise UsageError("Codex refresh produced no access token.") from exc
            headers["Authorization"] = f"Bearer {access_token}"
            usage = http_json(CODEX_USAGE_URL, headers=headers, timeout=timeout)
        else:
            raise

    write_json_atomic(path, auth_data, mode=0o600)

    rate_limit = usage.get("rate_limit") if isinstance(usage.get("rate_limit"), dict) else {}
    primary = rate_limit.get("primary_window") if isinstance(rate_limit.get("primary_window"), dict) else {}
    secondary = rate_limit.get("secondary_window") if isinstance(rate_limit.get("secondary_window"), dict) else {}

    summary = scan_codex_local_usage(
        codex_home=codex_home_dir(),
        since_day=dt.date.today() - dt.timedelta(days=29),
        until_day=dt.date.today(),
    )

    return {
        "provider": "codex",
        "plan": usage.get("plan_type"),
        "session_remaining": pct_remaining(primary.get("used_percent")),
        "weekly_remaining": pct_remaining(secondary.get("used_percent")),
        "session_reset": to_iso_z(parse_epoch_seconds(primary.get("reset_at"))),
        "weekly_reset": to_iso_z(parse_epoch_seconds(secondary.get("reset_at"))),
        "today_tokens": summary["today_tokens"],
        "today_cost_usd": summary["today_cost_usd"],
        "last30_tokens": summary["last30_tokens"],
        "last30_cost_usd": summary["last30_cost_usd"],
        "extra_used": None,
        "extra_limit": None,
        "extra_currency": None,
    }



def claude_credentials_file() -> Path:
    explicit = os.environ.get("WAYBAR_AI_CLAUDE_CREDENTIALS_FILE", "").strip()
    if explicit:
        return Path(explicit).expanduser()
    return Path.home() / ".claude" / ".credentials.json"



def claude_refresh(creds: dict, timeout: float) -> dict:
    oauth = creds.get("claudeAiOauth") if isinstance(creds.get("claudeAiOauth"), dict) else {}
    refresh_token = str(oauth.get("refreshToken") or "").strip()
    if not refresh_token:
        raise UsageError("Claude refresh token missing. Run `claude login`.")

    client_id = os.environ.get("WAYBAR_AI_CLAUDE_CLIENT_ID", "").strip() or CLAUDE_CLIENT_ID_DEFAULT
    body = urllib.parse.urlencode(
        {
            "grant_type": "refresh_token",
            "refresh_token": refresh_token,
            "client_id": client_id,
        }
    ).encode("utf-8")

    retries = max(1, to_int(os.environ.get("WAYBAR_AI_CLAUDE_REFRESH_RETRIES", "3")))
    refreshed: dict | None = None

    for attempt in range(retries):
        try:
            refreshed = http_json(
                CLAUDE_REFRESH_ENDPOINT,
                headers={
                    "Content-Type": "application/x-www-form-urlencoded",
                    "Accept": "application/json",
                    "User-Agent": "waybar-ai-usage",
                },
                timeout=timeout,
                method="POST",
                body=body,
            )
            break
        except UsageError as exc:
            message = str(exc)
            lower = message.lower()
            if "invalid_grant" in lower:
                raise UsageError("Claude OAuth refresh token invalid. Run `claude login`.") from exc
            if is_http_5xx_error(message):
                if attempt + 1 < retries:
                    backoff = min(1.5, 0.35 * (2**attempt))
                    time.sleep(backoff)
                    continue
                raise UsageError("Claude OAuth refresh endpoint is temporarily unavailable (HTTP 5xx).") from exc
            raise

    if refreshed is None:
        raise UsageError("Claude OAuth refresh did not return credentials.")

    access = str(refreshed.get("access_token") or "").strip()
    if not access:
        raise UsageError("Claude refresh returned no access token.")

    oauth["accessToken"] = access
    new_refresh = str(refreshed.get("refresh_token") or "").strip()
    if new_refresh:
        oauth["refreshToken"] = new_refresh

    expires_in = to_int(refreshed.get("expires_in"))
    if expires_in > 0:
        oauth["expiresAt"] = int((time.time() + expires_in) * 1000)

    scope = refreshed.get("scope")
    if isinstance(scope, str) and scope.strip():
        oauth["scopes"] = [part for part in scope.strip().split(" ") if part]

    creds["claudeAiOauth"] = oauth
    return creds



def claude_fetch(timeout: float) -> dict:
    path = claude_credentials_file()
    creds = read_json(path)
    oauth = creds.get("claudeAiOauth") if isinstance(creds.get("claudeAiOauth"), dict) else {}

    access_override = os.environ.get("WAYBAR_AI_CLAUDE_ACCESS_TOKEN", "").strip()
    access_token = access_override or str(oauth.get("accessToken") or "").strip()
    if not access_token:
        raise UsageError("Claude token missing. Run `claude login`.")

    expires_at = parse_epoch_millis(oauth.get("expiresAt"))
    refresh_failed_5xx = False
    if expires_at and now_utc() >= expires_at:
        try:
            creds = claude_refresh(creds, timeout=timeout)
            oauth = creds.get("claudeAiOauth") if isinstance(creds.get("claudeAiOauth"), dict) else {}
            access_token = str(oauth.get("accessToken") or "").strip()
        except UsageError as exc:
            if is_http_5xx_error(str(exc)):
                # Keep going with the current token; we'll only fail if usage also requires refresh.
                refresh_failed_5xx = True
            else:
                raise

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json",
        "Content-Type": "application/json",
        "anthropic-beta": CLAUDE_USAGE_BETA,
        "User-Agent": "waybar-ai-usage",
    }

    try:
        usage = http_json(CLAUDE_USAGE_URL, headers=headers, timeout=timeout)
    except UsageError as exc:
        message = str(exc)
        lower = message.lower()
        if is_http_status(message, 401) and "token_expired" in lower:
            try:
                creds = claude_refresh(creds, timeout=timeout)
            except UsageError as refresh_exc:
                if is_http_5xx_error(str(refresh_exc)):
                    raise UsageError(
                        "Claude OAuth refresh endpoint is temporarily unavailable (HTTP 5xx). Try again shortly."
                    ) from refresh_exc
                raise

            oauth = creds.get("claudeAiOauth") if isinstance(creds.get("claudeAiOauth"), dict) else {}
            access_token = str(oauth.get("accessToken") or "").strip()
            if not access_token:
                raise UsageError("Claude refresh produced no access token.") from exc
            headers["Authorization"] = f"Bearer {access_token}"

            try:
                usage = http_json(CLAUDE_USAGE_URL, headers=headers, timeout=timeout)
            except UsageError as retry_exc:
                if is_http_5xx_error(str(retry_exc)):
                    raise UsageError("Claude usage API is temporarily unavailable (HTTP 5xx).") from retry_exc
                raise
        elif is_http_5xx_error(message):
            raise UsageError("Claude usage API is temporarily unavailable (HTTP 5xx).") from exc
        elif refresh_failed_5xx:
            raise UsageError("Claude OAuth refresh endpoint is temporarily unavailable (HTTP 5xx). Try again shortly.") from exc
        else:
            raise

    write_json_atomic(path, creds, mode=0o600)

    five = usage.get("five_hour") if isinstance(usage.get("five_hour"), dict) else {}
    seven = usage.get("seven_day") if isinstance(usage.get("seven_day"), dict) else {}
    extra = usage.get("extra_usage") if isinstance(usage.get("extra_usage"), dict) else {}

    summary = scan_claude_local_usage(
        since_day=dt.date.today() - dt.timedelta(days=29),
        until_day=dt.date.today(),
    )

    extra_used = extra.get("used_credits")
    extra_limit = extra.get("monthly_limit")
    extra_currency = str(extra.get("currency") or "USD").strip().upper() if extra else None
    if isinstance(extra_used, (int, float)):
        extra_used = float(extra_used) / 100.0
    else:
        extra_used = None
    if isinstance(extra_limit, (int, float)):
        extra_limit = float(extra_limit) / 100.0
    else:
        extra_limit = None

    return {
        "provider": "claude",
        "plan": oauth.get("rateLimitTier") or oauth.get("subscriptionType"),
        "session_remaining": pct_remaining(five.get("utilization")),
        "weekly_remaining": pct_remaining(seven.get("utilization")),
        "session_reset": to_iso_z(parse_iso8601(str(five.get("resets_at") or ""))),
        "weekly_reset": to_iso_z(parse_iso8601(str(seven.get("resets_at") or ""))),
        "today_tokens": summary["today_tokens"],
        "today_cost_usd": summary["today_cost_usd"],
        "last30_tokens": summary["last30_tokens"],
        "last30_cost_usd": summary["last30_cost_usd"],
        "extra_used": extra_used,
        "extra_limit": extra_limit,
        "extra_currency": extra_currency,
    }


# ---------------------------------------------------------------------------
# Waybar rendering + cache
# ---------------------------------------------------------------------------


def state_dir() -> Path:
    explicit = os.environ.get("WAYBAR_AI_STATE_DIR", "").strip()
    if explicit:
        return Path(explicit).expanduser()
    xdg_state = os.environ.get("XDG_STATE_HOME", "").strip()
    base = Path(xdg_state).expanduser() if xdg_state else Path.home() / ".local" / "state"
    return base / "waybar" / "ai-usage"



def state_file(provider: str) -> Path:
    return state_dir() / f"{provider}.json"



def load_state(provider: str) -> dict | None:
    path = state_file(provider)
    if not path.exists():
        return None
    try:
        with path.open("r", encoding="utf-8") as fh:
            data = json.load(fh)
        if isinstance(data, dict):
            return data
    except (OSError, json.JSONDecodeError):
        return None
    return None



def save_state(provider: str, metrics: dict) -> None:
    payload = {
        "provider": provider,
        "fetched_at": time.time(),
        "metrics": metrics,
    }
    write_json_atomic(state_file(provider), payload, mode=0o600)



def severity_class(weekly_remaining: float | None) -> str:
    if weekly_remaining is None:
        return "unknown"
    if weekly_remaining <= 10:
        return "critical"
    if weekly_remaining <= 20:
        return "warning"
    return "normal"



def provider_icon(provider: str) -> str:
    if provider == "codex":
        return os.environ.get("WAYBAR_AI_CODEX_ICON", "\ue7cf")
    return os.environ.get("WAYBAR_AI_CLAUDE_ICON", "\ue861")



def build_tooltip(metrics: dict, fetched_at: float, stale_error: str | None = None) -> str:
    provider = metrics.get("provider", "")
    title = "Codex" if provider == "codex" else "Claude"

    session_reset = as_datetime(metrics.get("session_reset"))
    weekly_reset = as_datetime(metrics.get("weekly_reset"))

    lines: list[str] = [f"{title} usage"]
    lines.append(f"Session remaining: {fmt_percent(metrics.get('session_remaining'))}")
    lines.append(
        "Session reset: "
        + (
            f"{reset_absolute_text(session_reset)} ({reset_countdown_text(session_reset)})"
            if session_reset
            else "—"
        )
    )
    lines.append(f"Weekly remaining: {fmt_percent(metrics.get('weekly_remaining'))}")
    lines.append(
        "Weekly reset: "
        + (
            f"{reset_absolute_text(weekly_reset)} ({reset_countdown_text(weekly_reset)})"
            if weekly_reset
            else "—"
        )
    )

    today_cost = fmt_usd(metrics.get("today_cost_usd"))
    today_tokens = fmt_tokens(metrics.get("today_tokens"))
    month_cost = fmt_usd(metrics.get("last30_cost_usd"))
    month_tokens = fmt_tokens(metrics.get("last30_tokens"))

    lines.append(f"Today: {today_cost} · {today_tokens} tokens")
    lines.append(f"Last 30 days: {month_cost} · {month_tokens} tokens")

    if provider == "claude" and metrics.get("extra_used") is not None and metrics.get("extra_limit") is not None:
        currency = metrics.get("extra_currency") or "USD"
        used = fmt_money(metrics.get("extra_used"), currency)
        limit = fmt_money(metrics.get("extra_limit"), currency)
        lines.append(f"Extra usage: {used} / {limit}")

    plan = metrics.get("plan")
    if isinstance(plan, str) and plan.strip():
        lines.append(f"Plan: {plan.strip()}")

    age = time.time() - fetched_at
    lines.append(f"Updated: {format_relative(age)}")

    if stale_error:
        lines.append("")
        lines.append(f"Cached data (refresh failed): {stale_error}")

    return "\n".join(lines)



def build_waybar_output(metrics: dict, fetched_at: float, stale_error: str | None = None) -> dict:
    provider = metrics.get("provider", "codex")
    icon = provider_icon(provider)
    weekly_remaining = metrics.get("weekly_remaining")
    text = f"{icon} {fmt_percent(weekly_remaining)}"

    classes = [provider, severity_class(weekly_remaining)]
    if stale_error:
        classes.append("stale")

    return {
        "text": text,
        "tooltip": build_tooltip(metrics, fetched_at=fetched_at, stale_error=stale_error),
        "class": " ".join(classes),
    }



def output_error(provider: str, message: str) -> None:
    icon = provider_icon(provider)
    payload = {
        "text": f"{icon} --",
        "tooltip": message,
        "class": f"{provider} error",
    }
    print(json.dumps(payload, ensure_ascii=False))


# ---------------------------------------------------------------------------
# Entry
# ---------------------------------------------------------------------------


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("provider", choices=["codex", "claude"])
    parser.add_argument("--refresh", action="store_true")
    args = parser.parse_args()

    load_env_file(Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))).expanduser() / "waybar" / "ai-usage.env")

    timeout = float(os.environ.get("WAYBAR_AI_TIMEOUT_SECONDS", "15"))
    cache_ttl = int(os.environ.get("WAYBAR_AI_CACHE_TTL_SECONDS", "75"))

    cached = load_state(args.provider)
    if cached and not args.refresh:
        fetched_at = float(cached.get("fetched_at") or 0)
        metrics = cached.get("metrics") if isinstance(cached.get("metrics"), dict) else None
        if metrics and (time.time() - fetched_at) < cache_ttl:
            print(json.dumps(build_waybar_output(metrics, fetched_at=fetched_at), ensure_ascii=False))
            return 0

    try:
        if args.provider == "codex":
            metrics = codex_fetch(timeout=timeout)
        else:
            metrics = claude_fetch(timeout=timeout)

        save_state(args.provider, metrics)
        print(json.dumps(build_waybar_output(metrics, fetched_at=time.time()), ensure_ascii=False))
        return 0
    except Exception as exc:  # noqa: BLE001
        error_message = str(exc)
        if cached:
            fetched_at = float(cached.get("fetched_at") or 0)
            metrics = cached.get("metrics") if isinstance(cached.get("metrics"), dict) else None
            if metrics:
                print(
                    json.dumps(
                        build_waybar_output(metrics, fetched_at=fetched_at, stale_error=error_message),
                        ensure_ascii=False,
                    )
                )
                return 0

        output_error(args.provider, error_message)
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
