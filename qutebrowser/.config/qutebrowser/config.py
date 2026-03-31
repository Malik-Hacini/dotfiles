import json
import os
from pathlib import Path

# load your autoconfig, use this, if the rest of your config is empty!
config.load_autoconfig()

def load_wal_palette():
    cache_home = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    colors_path = cache_home / "wal" / "colors.json"

    try:
        data = json.loads(colors_path.read_text())
    except (FileNotFoundError, OSError, ValueError, TypeError):
        return None

    colors = data.get("colors", {})
    special = data.get("special", {})
    palette = {
        "rosewater": special.get("foreground"),
        "flamingo": colors.get("color7"),
        "pink": colors.get("color5"),
        "mauve": colors.get("color5"),
        "red": colors.get("color1"),
        "maroon": colors.get("color9") or colors.get("color1"),
        "peach": colors.get("color3"),
        "yellow": colors.get("color11") or colors.get("color3"),
        "green": colors.get("color2"),
        "teal": colors.get("color6"),
        "sky": colors.get("color14") or colors.get("color6"),
        "sapphire": colors.get("color6"),
        "blue": colors.get("color4"),
        "lavender": colors.get("color12") or colors.get("color4"),
        "text": special.get("foreground"),
        "subtext1": colors.get("color15") or special.get("foreground"),
        "subtext0": colors.get("color7") or special.get("foreground"),
        "overlay2": colors.get("color8") or colors.get("color0"),
        "overlay1": colors.get("color8") or colors.get("color0"),
        "overlay0": colors.get("color8") or colors.get("color0"),
        "surface2": colors.get("color8") or colors.get("color0"),
        "surface1": colors.get("color0"),
        "surface0": colors.get("color0"),
        "base": special.get("background"),
        "mantle": colors.get("color0") or special.get("background"),
        "crust": colors.get("color0") or special.get("background"),
    }

    return palette if all(palette.values()) else None


if os.path.exists(config.configdir / "theme.py"):
    import theme

    wal_palette = load_wal_palette()
    if wal_palette is None:
        theme.setup(c, "mocha", False)
    else:
        theme.setup(c, "mocha", False, wal_palette)

# Always hide the tab bar.
c.tabs.show = "never"
