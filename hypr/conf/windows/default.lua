hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = { top = 5, right = 0, bottom = 0, left = 0 },
        border_size = 2,
        col = {
            active_border   = { colors = {primary, on_primary}, angle = 90 },
            inactive_border = on_primary,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    }
})