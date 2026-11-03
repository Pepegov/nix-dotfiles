#!/usr/bin/env python3
import html
import os
import subprocess
from html.parser import HTMLParser


class PangoFormatter(HTMLParser):
    tag_names = {
        "b": "b",
        "strong": "b",
        "i": "i",
        "em": "i",
        "u": "u",
        "s": "s",
        "del": "s",
    }

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts = []
        self.open_tags = []
        self.has_markup = False

    def handle_starttag(self, tag, attrs):
        if tag in ("br", "p", "div", "li"):
            self.parts.append("\n")
            self.has_markup = True
            return

        replacement = self.tag_names.get(tag)
        if replacement:
            self.parts.append(f"<{replacement}>")
            self.open_tags.append((tag, replacement))
            self.has_markup = True

    def handle_endtag(self, tag):
        if tag in ("p", "div", "li"):
            self.parts.append("\n")
            return

        for index in range(len(self.open_tags) - 1, -1, -1):
            original, replacement = self.open_tags[index]
            if original == tag:
                inner_tags = self.open_tags[index + 1:]
                for _, inner_replacement in reversed(inner_tags):
                    self.parts.append(f"</{inner_replacement}>")
                self.parts.append(f"</{replacement}>")
                del self.open_tags[index:]
                for inner_original, inner_replacement in inner_tags:
                    self.parts.append(f"<{inner_replacement}>")
                    self.open_tags.append((inner_original, inner_replacement))
                return

    def handle_data(self, data):
        self.parts.append(html.escape(data, quote=False))

    def close_open_tags(self):
        for _, replacement in reversed(self.open_tags):
            self.parts.append(f"</{replacement}>")
        self.open_tags.clear()


def main():
    body = os.environ.get("DUNST_BODY", "")
    formatter = PangoFormatter()
    formatter.feed(html.unescape(body))
    formatter.close()
    formatter.close_open_tags()

    if formatter.has_markup:
        rendered_body = "".join(formatter.parts).rstrip("\n")
    else:
        rendered_body = html.escape(html.unescape(body), quote=False)

    notification_id = os.environ.get("DUNST_ID")
    if notification_id:
        subprocess.run(["dunstctl", "close", notification_id], check=False)

    timeout_ms = os.environ.get("DUNST_TIMEOUT", "0")
    try:
        timeout_ms = str(max(0, int(timeout_ms)))
    except ValueError:
        timeout_ms = "0"

    command = [
        "notify-send",
        "-a", "KDE Connect formatted",
        "-u", os.environ.get("DUNST_URGENCY", "NORMAL").lower(),
        "-t", timeout_ms,
    ]
    icon_path = os.environ.get("DUNST_ICON_PATH", "")
    if icon_path:
        command.extend(["-i", icon_path])

    category = os.environ.get("DUNST_CATEGORY", "")
    if category:
        command.extend(["-c", category])

    stack_tag = os.environ.get("DUNST_STACK_TAG", "")
    if stack_tag:
        command.extend(["-h", f"string:x-dunst-stack-tag:{stack_tag}"])

    command.extend([
        os.environ.get("DUNST_SUMMARY", ""),
        rendered_body,
    ])
    subprocess.run(command, check=False)


if __name__ == "__main__":
    main()
