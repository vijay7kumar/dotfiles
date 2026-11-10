[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
export WEBKIT_DISABLE_DMABUF_RENDERER=1
ulimit -n 65535 2>/dev/null
