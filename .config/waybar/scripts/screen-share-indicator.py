#!/usr/bin/python3
"""Show Hyprland screen shares in Waybar and outline their targets."""

import json
import os
import socket
import subprocess
import sys
import time
from pathlib import Path

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, GLib, Gtk, GtkLayerShell


COLOR = "#e81123"
WIDTH = 3
START_DELAY = 0.7
STOP_DELAY = 1.5
STATE_FILE = Path(os.environ["XDG_RUNTIME_DIR"]) / "screen-share-indicator.json"


def status():
    try:
        if time.time() - STATE_FILE.stat().st_mtime > 2:
            raise FileNotFoundError
        print(STATE_FILE.read_text())
    except FileNotFoundError:
        print(json.dumps({
            "text": "󰶐", "class": "error",
            "tooltip": "Screen share indicator is not running",
        }, ensure_ascii=False))


def hyprctl(command):
    result = subprocess.run(
        ["hyprctl", "-j", command], capture_output=True, text=True, check=True
    )
    return json.loads(result.stdout)


class Border:
    def __init__(self, monitor, x, y, width, height):
        self.windows = []
        geometry = monitor.get_geometry()
        x -= geometry.x
        y -= geometry.y
        edges = (
            (x, y, width, WIDTH),
            (x, y + height - WIDTH, width, WIDTH),
            (x, y + WIDTH, WIDTH, height - 2 * WIDTH),
            (x + width - WIDTH, y + WIDTH, WIDTH, height - 2 * WIDTH),
        )
        for left, top, edge_width, edge_height in edges:
            if edge_width <= 0 or edge_height <= 0:
                continue
            window = Gtk.Window()
            window.set_decorated(False)
            window.set_size_request(edge_width, edge_height)
            GtkLayerShell.init_for_window(window)
            GtkLayerShell.set_namespace(window, "screen-share-border")
            GtkLayerShell.set_layer(window, GtkLayerShell.Layer.OVERLAY)
            GtkLayerShell.set_monitor(window, monitor)
            GtkLayerShell.set_keyboard_mode(window, GtkLayerShell.KeyboardMode.NONE)
            GtkLayerShell.set_exclusive_zone(window, 0)
            GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, True)
            GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.LEFT, True)
            GtkLayerShell.set_margin(window, GtkLayerShell.Edge.TOP, top)
            GtkLayerShell.set_margin(window, GtkLayerShell.Edge.LEFT, left)
            window.get_style_context().add_class("screen-share-border")
            window.show_all()
            window.get_window().set_pass_through(True)
            self.windows.append(window)

    def destroy(self):
        for window in self.windows:
            window.destroy()


class Indicator:
    def __init__(self):
        self.sessions = {}
        self.borders = {}
        self.buffer = b""
        self.socket = socket.socket(socket.AF_UNIX)
        path = Path(os.environ["XDG_RUNTIME_DIR"]) / "hypr" / os.environ[
            "HYPRLAND_INSTANCE_SIGNATURE"
        ] / ".socket2.sock"
        self.socket.connect(str(path))
        self.socket.setblocking(False)
        GLib.io_add_watch(self.socket.fileno(), GLib.IO_IN | GLib.IO_HUP, self.on_socket)
        GLib.timeout_add(500, self.refresh)
        self.publish([])

    def on_socket(self, _fd, condition):
        if condition & GLib.IO_HUP:
            Gtk.main_quit()
            return False
        try:
            data = self.socket.recv(65536)
        except BlockingIOError:
            return True
        if not data:
            Gtk.main_quit()
            return False
        self.buffer += data
        while b"\n" in self.buffer:
            line, self.buffer = self.buffer.split(b"\n", 1)
            if not line.startswith(b"screencastv2>>"):
                continue
            try:
                state, owner, name = line.decode().split(">>", 1)[1].split(",", 2)
            except ValueError:
                continue
            key = (owner, name)
            now = time.monotonic()
            session = self.sessions.get(key)
            if state == "1":
                if session is None:
                    self.sessions[key] = {
                        "count": 1, "since": now, "until": None,
                        "shown": False, "addresses": set(),
                    }
                else:
                    session["count"] += 1
                    session["until"] = None
            elif state == "0" and session is not None:
                session["count"] = max(0, session["count"] - 1)
                if session["count"] == 0:
                    session["until"] = now + STOP_DELAY
        return True

    def refresh(self):
        now = time.monotonic()
        for key, session in list(self.sessions.items()):
            if session["count"] and now - session["since"] >= START_DELAY:
                session["shown"] = True
            if session["count"] == 0 and (
                not session["shown"] or now >= session["until"]
            ):
                del self.sessions[key]

        active = [
            key for key, session in self.sessions.items()
            if session["shown"]
        ]
        self.publish(active)
        if not active:
            self.set_borders({})
            return True

        try:
            monitors = hyprctl("monitors")
            clients = hyprctl("clients")
        except (subprocess.CalledProcessError, json.JSONDecodeError) as error:
            print(f"screen-share-indicator: {error}", file=sys.stderr)
            return True

        display = Gdk.Display.get_default()
        gdk_monitors = {
            monitor["name"]: display.get_monitor_at_point(
                monitor["x"] + round(monitor["width"] / monitor["scale"] / 2),
                monitor["y"] + round(monitor["height"] / monitor["scale"] / 2),
            )
            for monitor in monitors
        }
        targets = {}
        for owner, name in active:
            session = self.sessions[(owner, name)]
            monitor = next((m for m in monitors if m["name"] == name), None)
            if monitor is not None:
                rect = (
                    monitor["x"], monitor["y"],
                    round(monitor["width"] / monitor["scale"]),
                    round(monitor["height"] / monitor["scale"]),
                )
                targets[(owner, name)] = (rect, monitor["name"])
                continue

            for client in clients:
                if client["title"] != name and client["address"] not in session["addresses"]:
                    continue
                session["addresses"].add(client["address"])
                if client.get("hidden"):
                    continue
                monitor = next((m for m in monitors if m["id"] == client["monitor"]), None)
                if monitor is None:
                    continue
                workspace = client["workspace"]["id"]
                if not client.get("pinned") and workspace not in (
                    monitor["activeWorkspace"]["id"],
                    monitor["specialWorkspace"]["id"],
                ):
                    continue
                targets[(owner, name, client["address"])] = (
                    (*client["at"], *client["size"]), monitor["name"]
                )

        desired = {}
        for key, (rect, monitor_name) in targets.items():
            x, y, width, height = rect
            gdk_monitor = gdk_monitors[monitor_name]
            if gdk_monitor is not None:
                desired[key] = (gdk_monitor, x, y, width, height)
        self.set_borders(desired)
        return True

    def set_borders(self, desired):
        for key, (geometry, border) in list(self.borders.items()):
            if key not in desired or desired[key] != geometry:
                border.destroy()
                del self.borders[key]
        for key, geometry in desired.items():
            if key not in self.borders:
                self.borders[key] = (geometry, Border(*geometry))

    def publish(self, active):
        tooltip = "\n".join(f"Sharing: {name}" for _owner, name in active)
        output = json.dumps({
            "text": "󰍹" if active else "󰶐",
            "class": "sharing" if active else "idle",
            "tooltip": tooltip or "Nothing is being shared",
        }, ensure_ascii=False)
        temporary = STATE_FILE.with_suffix(".tmp")
        temporary.write_text(output)
        temporary.replace(STATE_FILE)


def main():
    css = Gtk.CssProvider()
    css.load_from_data(f".screen-share-border {{ background: {COLOR}; }}".encode())
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )
    Indicator()
    Gtk.main()


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--status":
        status()
    else:
        main()
