#
# ~/.bashrc — loads the modular config in ~/.config/bashrc/
#
[[ $- != *i* ]] && return

for f in "$HOME"/.config/bashrc/*; do
    [[ -f $f ]] && . "$f"
done
unset f
