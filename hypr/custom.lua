-- -----------------------------------------------------
-- Custom rice tweaks (kept here so ML4W variant switches don't overwrite them)
-- -----------------------------------------------------

-- Frosted-glass blur behind bar, launcher, notifications, power menu, widgets.
-- ignore_alpha skips fully transparent pixels so only the pills/cards get blurred.
for _, ns in ipairs({
    "waybar", "rofi", "swaync-control-center", "swaync-notification-window",
    "logout_dialog", "quickshell", "swayosd",
}) do
    hl.layer_rule({ match = { namespace = ns }, blur = true, ignore_alpha = 0.2 })
end

-- Slide-in for notifications, fade for the power menu
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })

-- Screenshot annotator: floating, centred
hl.window_rule({ name = "satty", match = { class = "com.gabm.satty" }, float = true, center = true, size = "1200 750" })

-- -----------------------------------------------------
-- Focus: dim unfocused windows slightly; per-app opacity
-- -----------------------------------------------------
hl.config({
    decoration = {
        inactive_opacity = 1.0,     -- opacity is set per app below instead of globally
        dim_inactive = true,
        dim_strength = 0.12,
    },
})

-- Slightly see-through app windows (focused / unfocused)
hl.window_rule({
    name = "rice-translucent-apps",
    match = { class = "^(org\\.gnome\\.Nautilus|dev\\.zed\\.Zed|code|Code|Spotify|spotify|vesktop|discord|obsidian|org\\.pulseaudio\\.pavucontrol)$" },
    opacity = "0.96 0.90",
})

-- Video, browsers and games: never dimmed, never transparent
hl.window_rule({
    name = "rice-solid-media",
    match = { class = "^(firefox|zen|zen-browser|mpv|vlc|steam_app_.*|Minecraft.*|org-tlauncher.*|gamescope)$" },
    no_dim = true,
    opaque = true,
})

-- Terminal music player: floating, centred
hl.window_rule({ name = "rice-music", match = { class = "com.rice.music" }, float = true, center = true, size = "1100 650" })
