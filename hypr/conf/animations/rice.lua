-- -----------------------------------------------------
-- Animations
-- name "Rice" — snappy (opens in 250ms), tuned for Intel UHD 620
-- -----------------------------------------------------
hl.config({ animations = { enabled = true } })

hl.curve("emphasized",  { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("emphAccel",   { type = "bezier", points = { {0.3, 0}, {0.8, 0.15} } })
hl.curve("spring",      { type = "bezier", points = { {0.34, 1.36}, {0.64, 1} } })
hl.curve("smoothOut",   { type = "bezier", points = { {0.36, 0}, {0.66, -0.56} } })
hl.curve("smoothIn",    { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })
hl.curve("easeOutQuint",{ type = "bezier", points = { {0.22, 1}, {0.36, 1} } })
hl.curve("linear",      { type = "bezier", points = { {0, 0}, {1, 1} } })

-- Windows: springy pop on open, quick shrink on close, smooth move
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 2.5, bezier = "emphasized",   style = "popin 90%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1.5, bezier = "emphAccel",    style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.5,   bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 2,   bezier = "smoothIn" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 1.5, bezier = "emphAccel" })
hl.animation({ leaf = "fadeSwitch",  enabled = true, speed = 2,   bezier = "smoothIn" })
hl.animation({ leaf = "fadeDim",     enabled = true, speed = 2,   bezier = "smoothIn" })

-- Border colour fade (rotating border disabled: it redraws every frame forever)
hl.animation({ leaf = "border",      enabled = true, speed = 6,   bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle", enabled = false })

-- Layers (bar, rofi, notifications, menus)
hl.animation({ leaf = "layersIn",      enabled = true, speed = 2,   bezier = "emphasized", style = "popin 93%" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,   bezier = "emphAccel",  style = "popin 93%" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2,   bezier = "smoothIn" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.5,   bezier = "emphAccel" })

-- Workspaces: slide with a light fade; scratchpad drops in vertically
hl.animation({ leaf = "workspaces",       enabled = true, speed = 3, bezier = "easeOutQuint", style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "emphasized",   style = "slidefadevert 20%" })
