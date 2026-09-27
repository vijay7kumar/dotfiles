#!/bin/bash

# 50/50 chance: Pokemon Pixel Art vs Custom Theme Image
CHOICE=$((RANDOM % 2))

if [ "$CHOICE" -eq 0 ]; then
    # ─── POKEMON PIXEL ART ───
    # Generate a random pokemon to a temporary file
    pokemon-colorscripts -r --no-title > /tmp/poke_fastfetch.txt
    
    # Run fastfetch with the text file as the logo
    fastfetch --logo-type file --logo /tmp/poke_fastfetch.txt --logo-padding-top 1 --logo-padding-left 2 --logo-padding-right 2
else
    # ─── CUSTOM THEME IMAGES ───
    CONFIG_DIR="$HOME/.config/fastfetch"
    THEMES_DIR="$CONFIG_DIR/themes"
    THEME_FILE="$CONFIG_DIR/current_theme"
    STATE_FILE="$CONFIG_DIR/current_state"

    # Default theme if none selected
    [ ! -f "$THEME_FILE" ] && echo "JujutsuKaisen" > "$THEME_FILE"

    THEME=$(cat "$THEME_FILE")
    THEME_DIR="$THEMES_DIR/$THEME"

    if [ ! -d "$THEME_DIR" ]; then
        fastfetch
        exit 0
    fi

    # Get all images in the theme folder
    mapfile -t images < <(
        find "$THEME_DIR" -maxdepth 1 \( -name "*.png" -o -name "*.gif" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) -exec basename {} \; | sort -V
    )

    if [ ${#images[@]} -eq 0 ]; then
        fastfetch
        exit 0
    fi

    # Pick the next image in sequence
    LAST=""
    [ -f "$STATE_FILE" ] && LAST=$(cat "$STATE_FILE")
    NEXT="${images[0]}"

    if [ -n "$LAST" ]; then
        for i in "${!images[@]}"; do
            if [ "${images[$i]}" = "$LAST" ]; then
                NEXT="${images[$(( (i + 1) % ${#images[@]} ))]}"
                break
            fi
        done
    fi

    echo "$NEXT" > "$STATE_FILE"
    IMAGE_PATH="$THEME_DIR/$NEXT"

    # Run fastfetch and strictly size the image so it isn't cut off or overflowing
    # Ghostty/Kitty supports this natively via the --logo-type kitty protocol
    fastfetch --logo-type kitty --logo "$IMAGE_PATH" --logo-width 30 --logo-height 15 --logo-padding-left 2 --logo-padding-right 2
fi
