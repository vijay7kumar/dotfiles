-- -----------------------------------------------------
-- General window decoration
-- name: "Default"
-- -----------------------------------------------------

hl.config({
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        fullscreen_opacity = 1.0,
        rounding_power = 2,

        shadow = {
            enabled = true,
            range = 16,
            render_power = 2,
            color = "rgba(00000050)",
        },

        blur = {
            enabled   = true,
            size      = 6,
            passes    = 2,     -- 2 passes ≈ same look, half the GPU cost
            new_optimizations = true,
            ignore_opacity = true,
            xray = true,
            popups = false,
            vibrancy  = 0.1696,
        },
    },
})