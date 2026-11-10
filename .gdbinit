# Load pwndbg only if it's installed (git clone https://github.com/pwndbg/pwndbg ~/pwndbg)
python
import os
p = os.path.expanduser("~/pwndbg/gdbinit.py")
if os.path.exists(p):
    gdb.execute("source " + p)
end
