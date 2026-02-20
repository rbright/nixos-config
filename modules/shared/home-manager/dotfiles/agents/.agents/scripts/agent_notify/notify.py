from __future__ import annotations

import json
import os
import platform
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from agent_notify.types import Notification

BELL = "\a"
SENDER_BUNDLE_ID = "com.github.wez.wezterm"
MESSAGE_LIMIT = 800


def title_from_cwd(cwd: str) -> str:
    if not cwd:
        return "agent"
    p = Path(cwd)
    return p.name or p.parent.name or "agent"


def _truncate(message: str, limit: int = MESSAGE_LIMIT) -> str:
    message = message or ""
    if len(message) <= limit:
        return message
    return message[:limit] + "..."


def _find_terminal_notifier() -> str | None:
    for candidate in (
        Path.home() / ".nix-profile/bin/terminal-notifier",
        Path("/nix/var/nix/profiles/default/bin/terminal-notifier"),
        Path("/usr/local/bin/terminal-notifier"),
        Path("/usr/bin/terminal-notifier"),
    ):
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return shutil.which("terminal-notifier")


def _find_busctl() -> str | None:
    for candidate in (
        Path("/run/current-system/sw/bin/busctl"),
        Path("/usr/bin/busctl"),
        Path("/bin/busctl"),
    ):
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return shutil.which("busctl")


def _find_notify_send() -> str | None:
    for candidate in (
        Path.home() / ".nix-profile/bin/notify-send",
        Path("/run/current-system/sw/bin/notify-send"),
        Path("/usr/bin/notify-send"),
        Path("/bin/notify-send"),
    ):
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return shutil.which("notify-send")


def _is_macos() -> bool:
    return platform.system() == "Darwin"


def _is_linux() -> bool:
    return platform.system() == "Linux"


def log_notification(notification: Notification) -> None:
    log_path = os.environ.get("AGENT_NOTIFY_LOG")
    if not log_path:
        return

    event = {
        "ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "mode": notification.mode,
        "title": title_from_cwd(notification.cwd),
        "cwd": notification.cwd,
        "message": notification.message,
    }
    try:
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(event, ensure_ascii=True) + "\n")
    except OSError:
        pass


def notify_macos(title: str, message: str) -> None:
    notifier = _find_terminal_notifier()
    if not notifier:
        return

    try:
        subprocess.run(
            [
                notifier,
                "-sender",
                SENDER_BUNDLE_ID,
                "-title",
                title,
                "-message",
                _truncate(message),
            ],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
    except OSError:
        pass


def notify_linux(title: str, message: str) -> None:
    busctl = _find_busctl()
    if busctl:
        try:
            subprocess.run(
                [
                    busctl,
                    "--user",
                    "call",
                    "org.freedesktop.Notifications",
                    "/org/freedesktop/Notifications",
                    "org.freedesktop.Notifications",
                    "Notify",
                    "susssasa{sv}i",
                    "agent-notify",
                    "0",
                    "",
                    title,
                    _truncate(message),
                    "0",
                    "0",
                    "5000",
                ],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
            return
        except OSError:
            pass

    notify_send = _find_notify_send()
    if not notify_send:
        return

    try:
        subprocess.run(
            [notify_send, title, _truncate(message)],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
    except OSError:
        pass


def _env_enabled(name: str, default: bool = True) -> bool:
    value = os.environ.get(name)
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def notify_terminal_bell() -> None:
    try:
        sys.stdout.write(BELL)
        sys.stdout.flush()
    except OSError:
        pass


def dispatch_notifications(notification: Notification) -> None:
    title = title_from_cwd(notification.cwd)
    if _is_macos() and _env_enabled("AGENT_NOTIFY_MACOS", default=True):
        notify_macos(title, notification.message)
    if _is_linux() and _env_enabled("AGENT_NOTIFY_LINUX", default=True):
        notify_linux(title, notification.message)
    if _env_enabled("AGENT_NOTIFY_BELL", default=True):
        notify_terminal_bell()
