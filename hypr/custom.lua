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
